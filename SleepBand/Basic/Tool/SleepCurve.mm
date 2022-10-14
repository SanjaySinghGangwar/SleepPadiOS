/********************************************************************************************
File:			SleepCurve.cpp

Author:			Wang Xiang

Date:			2018-07-25

Description:	进行睡眠曲线的计算，通过翻身次数和上床离床信息计算睡眠曲线
**********************************************************************************************/

#include "SleepCurve.h"

const short CURVE_POINT_INTERVAL	= 10;	/* 每个点之间间隔10秒 */

const short ONE_MINUTE_LEN 			= 60 / CURVE_POINT_INTERVAL;		/* 1分钟 */
const short TWO_MINUTE_LEN 			= (2 * 60) / CURVE_POINT_INTERVAL;	/* 2分钟 */
const short THREE_MINUTE_LEN 		= (3 * 60) / CURVE_POINT_INTERVAL;	/* 3分钟 */
const short FIVE_MINUTE_LEN 		= (5 * 60) / CURVE_POINT_INTERVAL;	/* 5分钟 */
const short FIFTEEN_MINUTE_LEN 		= (15 * 60) / CURVE_POINT_INTERVAL;	/* 15分钟 */
const short THIRTY_MINUTE_LEN 		= (30 * 60) / CURVE_POINT_INTERVAL;	/* 30分钟 */
const short TWENTY_MINUTE_LEN 		= (20 * 60) / CURVE_POINT_INTERVAL;	/* 20分钟 */
const short TEN_MINUTE_LEN 			= (10 * 60) / CURVE_POINT_INTERVAL;	/* 10分钟 */

const short ABED_MIN_LEN 			= FIFTEEN_MINUTE_LEN;

const short MAX_CNT_TURN_OVER 		= 3;	/* 3分钟内最大翻身次数　*/

const int INVALID_DATA_VALUE		= -65536;

const double EPSINON 				= 0.00000001;

struct Axis 
{
	int x;
	double y;
};

enum AbedStatus
{
	NON_ABED,		/* 离床状态 */
	ABED_START,		/* 上床状态 */
	ABED,			/* 在床状态 */
	ABED_END		/* 起床状态 */
};

/*****************************************************************

Function:       CSleepCurve()

Description:    构造函数

Calls:          无

Input:          无

Output:         无

Return:         无

Others:         无

*******************************************************************/

CSleepCurve::CSleepCurve()
{
	m_sleepCurveAll = NULL;

	m_turnInfo.clear();
	m_bedInfo.clear();
}

/*****************************************************************

Function:       ~CSleepCurve()

Description:    析构函数

Calls:          无

Input:          无

Output:         无

Return:         无

Others:         无

*******************************************************************/

CSleepCurve::~CSleepCurve()
{
	if (NULL != m_sleepCurveAll)
	{
		delete[] m_sleepCurveAll;
		m_sleepCurveAll = NULL;
	}

	m_turnInfo.clear();
	m_bedInfo.clear();
}

/*****************************************************************************

Function:       CalcSleepCurve()

Description:    计算睡眠质量曲线

Calls:          获取翻身状态和在床离床状态函数：GetTurnAndBedInfo()
				初始化曲线函数：InitCurve()
				根据翻身次数设置曲线值函数：SetValue()
				插值函数：Interpolation()
				计算睡眠质量时间函数：CalcSleepQualityTime()
				睡眠结果复制函数：ResultCopy()

Input:          睡眠数据 sleepData,
				睡眠数据长度 sdLen,
				睡眠质量曲线 sleepCurve,
				睡眠质量曲线长度 scLen
				统计开始标记 cntStartIndex
				上床和离床标记 abedFlagTime
				上床离床标记数组长度 aftLen


Output:         睡眠质量曲线 sleepCurve,
				睡眠质量时间统计 sqTime
				上床和离床标记 abedFlagTime


Return:         无

Others:         无

******************************************************************************/

void CSleepCurve::CalcSleepCurve(
	const unsigned char *sleepData,		/* 睡眠数据 */
	int sdLen,							/* 睡眠数据长度 */
	double *sleepCurve,					/* 睡眠曲线数据 */
	int scLen,							/* 睡眠曲线数据长度 */
	int cntStartIndex,					/* 统计开始标记 */
	int *abedFlagTime,					/* 上床和离床标记，在睡眠曲线里的下标 */
	int aftLen,							/* 上床离床标记数组长度 */
	SleepQualityTime &sqTime			/* 各睡眠质量时间统计 */
)
{
	if ((NULL == sleepData) || (NULL == sleepCurve) || (sdLen <= 0) || (scLen <= 0))
	{
		return;
	}

	m_cntStartIndex = cntStartIndex * THREE_MINUTE_LEN;

	m_scLenAll = sdLen * THREE_MINUTE_LEN;
	m_sleepCurveAll = new double[m_scLenAll];
	if (NULL == m_sleepCurveAll)
	{
		return;
	}

	GetTurnAndBedInfo(sleepData, sdLen);

	InitCurve();

	for (int i = 0; i < m_bedInfo.size(); ++i)
	{
		SetValue(m_bedInfo[i].startBed, m_bedInfo[i].finishBed);
	}

	Interpolation();

	ResultCopy(sleepCurve, scLen, abedFlagTime, aftLen);

	CalcSleepQualityTime(sleepCurve, scLen, abedFlagTime, aftLen, sqTime);
}

/*****************************************************************

Function:       SetValue()

Description:    根据翻身次数，设定睡眠曲线上各时间点的值

Calls:          计算一段时间内的翻身次数函数：CalcCntTurnOver()

Input:          无

Output:         无

Return:         无

Others:         无

*******************************************************************/

void CSleepCurve::SetValue(int startSeg, int endSeg)
{
	std::vector<TurnInfo> turnInfo;
	turnInfo.clear();

	for (int i = 0; i < m_turnInfo.size(); ++i)
	{
		if (m_turnInfo[i].time < startSeg)
		{
			continue;
		}
		else if ((INVALID_DATA_VALUE != endSeg) && (m_turnInfo[i].time > endSeg))
		{
			break;
		}

		turnInfo.push_back(m_turnInfo[i]);
	}

	/* 2018-09-27 更新全程无翻身的情况 */
	if (turnInfo.empty())
	{
		if (endSeg == INVALID_DATA_VALUE)
		{
			/* 5分钟浅睡，10分钟中睡，15分钟深睡*/
			for (int i = 0; i < 4; ++i)
			{
				m_sleepCurveAll[startSeg + i * FIVE_MINUTE_LEN] = 4.0 - i;
			}
			
			return;
		}
		
		int sleepSize = endSeg - startSeg;
		
		int step = (sleepSize > THIRTY_MINUTE_LEN) ? FIVE_MINUTE_LEN : sleepSize / 6;
		for (int i = 0; i < 4; ++i)
		{
			m_sleepCurveAll[startSeg + i * step] = 4.0 - i;
			m_sleepCurveAll[endSeg - i * step] = 4.0 - i;
		}
		
		return;
	}
	/* 2018-09-27 更新结束*/
	
	/* 寻找翻身间隔大于30分钟的位置点 */
	std::vector<int> deepSleepPos;
	deepSleepPos.clear();

	std::vector<int> midSleepPos;
	midSleepPos.clear();

	std::vector<int> lightSleepPos;
	lightSleepPos.clear();

	int sleepBegin = 0;

	/* 由深度睡眠来判断其他睡眠 */
	for (size_t i = 1; i < turnInfo.size(); ++i)
	{
		if (turnInfo[i].time - turnInfo[i - 1].time > THIRTY_MINUTE_LEN)
		{
			deepSleepPos.push_back(turnInfo[i - 1].time + THIRTY_MINUTE_LEN);
			midSleepPos.push_back(turnInfo[i - 1].time + TWENTY_MINUTE_LEN);
			lightSleepPos.push_back(turnInfo[i - 1].time + TEN_MINUTE_LEN);

			/* 深度睡眠截止点 */
			if (turnInfo[i].time - *(deepSleepPos.rbegin()) - TEN_MINUTE_LEN > 0)
			{
				m_sleepCurveAll[turnInfo[i].time - TEN_MINUTE_LEN] = 1.0;
			}
		}

		/* 入睡时间 */
		if ((0 == sleepBegin) && (turnInfo[i].time - turnInfo[i - 1].time > TEN_MINUTE_LEN))
		{
			sleepBegin = turnInfo[i - 1].time + TWO_MINUTE_LEN;
		}
	}

	if (0 == sleepBegin)
	{
		for (int i = startSeg; i < endSeg; ++i)
		{
			m_sleepCurveAll[i] = 4.0;
		}

		return;
	}

	int cntTwentyMinuteTurn = 0;
	for (size_t i = 0; i < lightSleepPos.size(); ++i)
	{
		int start 	= (lightSleepPos[i] - TEN_MINUTE_LEN < 0) ? 0 : lightSleepPos[i] - TWENTY_MINUTE_LEN;
		int end 	= lightSleepPos[i];

		cntTwentyMinuteTurn = CalcCntTurnOver(start, end);

		if (cntTwentyMinuteTurn <= 1)
		{
			m_sleepCurveAll[lightSleepPos[i]] = 2;
		}
		else if (cntTwentyMinuteTurn <= 2)
		{
			m_sleepCurveAll[lightSleepPos[i]] = 2.5;
		}
		else
		{
			m_sleepCurveAll[lightSleepPos[i]] = 3;
		}

		m_sleepCurveAll[midSleepPos[i]] 	= m_sleepCurveAll[lightSleepPos[i]] - 1;
		m_sleepCurveAll[deepSleepPos[i]] = m_sleepCurveAll[lightSleepPos[i]] - 2;
	}

	/***************************************************
	* 连续翻身三次， 进入浅度睡眠 
	* 连续翻身两次， 进入中度睡眠
	****************************************************/

	for (size_t i = 0; i < turnInfo.size(); ++i)
	{
		if (turnInfo[i].cnt == MAX_CNT_TURN_OVER)
		{
			m_sleepCurveAll[turnInfo[i].time] = 3.0;
		}
		else if (turnInfo[i].cnt == MAX_CNT_TURN_OVER - 1)
		{
			m_sleepCurveAll[turnInfo[i].time] = 2.0;
		}
	}

	/* 入睡时间延拓 */
	for (int i = startSeg; i < sleepBegin; ++i)
	{
		m_sleepCurveAll[i] = 4.0;
	}

	/* 连续20分钟无翻身，则状态改变 */
	const double DELTA_VALUE 	= 0.6;
	const double MIN_VALUE 		= 0.4;

	for (size_t i = 1; i < turnInfo.size(); ++i)
	{
		if (turnInfo[i].time - turnInfo[i - 1].time <= TWENTY_MINUTE_LEN)
		{
			continue;
		}

		/* 位置点未被修改 */
		int posTemp = turnInfo[i - 1].time + TEN_MINUTE_LEN;
		if ((m_sleepCurveAll[posTemp] <= EPSINON)
			&& (m_sleepCurveAll[posTemp] >= -EPSINON))
		{
			for (int k = posTemp; k >= 0; --k)
			{
				if (m_sleepCurveAll[k] > 0)
				{
					m_sleepCurveAll[posTemp] = (m_sleepCurveAll[k] - DELTA_VALUE < MIN_VALUE) ? MIN_VALUE : (m_sleepCurveAll[k] - DELTA_VALUE);
					break;
				}
			}
		}

		posTemp = turnInfo[i - 1].time + TWENTY_MINUTE_LEN;
		if (  (m_sleepCurveAll[posTemp] <= EPSINON)
			&& (m_sleepCurveAll[posTemp] >= -EPSINON))
		{
			int cntIntevalTemp = 0;
			for (int k = posTemp + 1; k < m_scLenAll; ++k)
			{
				if (m_sleepCurveAll[k] > 0)
				{
					break;
				}

				if (++cntIntevalTemp == FIVE_MINUTE_LEN)
				{
					m_sleepCurveAll[posTemp] = m_sleepCurveAll[posTemp - TEN_MINUTE_LEN] - DELTA_VALUE;
					m_sleepCurveAll[posTemp] = (m_sleepCurveAll[posTemp] < MIN_VALUE) ? MIN_VALUE : m_sleepCurveAll[posTemp];
					break;
				}
			}	// end of for (int k = posTemp + 1; k < scLen; ++k)
		}	// end of if (  (sleepCurve[posTemp] <= EPSINON) && (sleepCurve[posTemp] >= -EPSINON))
	}

	/* 2019-01-25, 起床之前的那次翻身，适当的往前移动，否则曲线拟合将会很陡峭 */
	int i = (INVALID_DATA_VALUE == endSeg) ? (m_scLenAll - 1) : (endSeg - 1);
	for (; i > FIFTEEN_MINUTE_LEN; --i)
	{
		if ((m_sleepCurveAll[i] > 0) && (m_sleepCurveAll[i] < 4.0))
		{
			m_sleepCurveAll[i - FIFTEEN_MINUTE_LEN] = m_sleepCurveAll[i];
			m_sleepCurveAll[i] = 0;
			break;
		}
	}

	turnInfo.clear();

	deepSleepPos.clear();
	midSleepPos.clear();
	lightSleepPos.clear();
}

/*****************************************************************

Function:       Interpolation()

Description:    对睡眠曲线上的点进行插值，以及三次样条拟合

Calls:          计算一段时间内的翻身次数函数：CalcCntTurnOver()
				三次样条曲线拟合函数：Spline()

Input:          无

Output:         无

Return:         无

Others:         无

*******************************************************************/

void CSleepCurve::Interpolation()
{
	std::vector<Axis> axisInfo;
	axisInfo.clear();

	Axis axisTemp;
	for (int i = 0; i < m_scLenAll; ++i)
	{
		if (m_sleepCurveAll[i] > 0)
		{
			axisTemp.x = i;
			axisTemp.y = m_sleepCurveAll[i];
			axisInfo.push_back(axisTemp);
		}
	}

	for (size_t i = 1; i < axisInfo.size(); ++i)
	{
		if (axisInfo[i].x - axisInfo[i-1].x <= TEN_MINUTE_LEN)
		{
			continue;
		}

		int start 			= axisInfo[i - 1].x;
		int end 			= axisInfo[i].x;
		double interval 	= end - start;
		int num 			= (int)((interval / ONE_MINUTE_LEN - 10) / 10);
		int interpInterval 	= (int)(interval / (num + 1) + 0.5);

		for (int k = 0; k < num; ++k)
		{
			int interpPos = start + (k + 1)*interpInterval;

			m_sleepCurveAll[interpPos] = (double)((m_sleepCurveAll[end] - m_sleepCurveAll[start]) * (interpPos - start)) / (double)(end - start)
				+ m_sleepCurveAll[start];

			int begin = interpPos - 7 * ONE_MINUTE_LEN;
			begin = (begin < 0) ? 0 : begin;
			int finish = interpPos + 7 * ONE_MINUTE_LEN;
			finish = (finish >= m_scLenAll) ? m_scLenAll - 1 : finish;

			int cntTurnOver = CalcCntTurnOver(begin, finish);

			double coef = (cntTurnOver < 2) ? -0.1 : ((cntTurnOver <= 3) ? 0.0 : 0.1);

			m_sleepCurveAll[interpPos] *= (1 + coef);
		}
	}

	axisInfo.clear();

	/* 三次样条插值 */
	int cntNonZero = 0;
	for (int i = 0; i < m_scLenAll; ++i)
	{
		cntNonZero += (m_sleepCurveAll[i] > 0) ? 1 : 0;
	}

	if (0 == cntNonZero)
	{
		return;
	}

	double *xNonZero = new double[cntNonZero];
	if (NULL == xNonZero)
	{
		return;
	}

	double *yNonZero = new double[cntNonZero];
	if (NULL == yNonZero)
	{
		delete[] xNonZero;
		xNonZero = NULL;

		return;
	}

	double *xZero = new double[m_scLenAll - cntNonZero];
	if (NULL == xZero)
	{
		delete[] xNonZero;
		xNonZero = NULL;

		delete[] yNonZero;
		yNonZero = NULL;

		return;
	}

	double *yZero = new double[m_scLenAll - cntNonZero];
	if (NULL == yZero)
	{
		delete[] xNonZero;
		xNonZero = NULL;

		delete[] yNonZero;
		yNonZero = NULL;

		delete[] xZero;
		xZero = NULL;

		return;
	}
	
	int indexNonZero 	= 0;
	int indexZero 		= 0;
	for (int i = 0; i < m_scLenAll; ++i)
	{
		if (m_sleepCurveAll[i] > 0)
		{
			xNonZero[indexNonZero] = i;
			yNonZero[indexNonZero] = m_sleepCurveAll[i];
			++indexNonZero;
		}
		else
		{
			xZero[indexZero] = i;
			++indexZero;
		}
	}

	Spline(xNonZero, yNonZero, cntNonZero, 0, 0, xZero, m_scLenAll - cntNonZero, yZero);

	for (int i = 0; i < m_scLenAll - cntNonZero; ++i)
	{
		m_sleepCurveAll[(int)xZero[i]] = yZero[i];
	}

	/* 数据最后一次进行限制 */
	for (int i = 0; i < m_scLenAll; ++i)
	{
		if (m_sleepCurveAll[i] > MAX_CURVE_VALUE)
		{
			m_sleepCurveAll[i] = MAX_CURVE_VALUE;
		}
		else if (m_sleepCurveAll[i] < MIN_CURVE_VALUE)
		{
			m_sleepCurveAll[i] = MIN_CURVE_VALUE;
		}
	}

	delete[] xNonZero;
	xNonZero = NULL;

	delete[] yNonZero;
	yNonZero = NULL;

	delete[] xZero;
	xZero = NULL;

	delete[] yZero;
	yZero = NULL;
}

/*****************************************************************

Function:       ResultCopy()

Description:    按统计索引复制睡眠质量数据

Calls:          无

Input:          睡眠质量曲线 sleepCurve,
				睡眠质量曲线长度 scLen，
				上床离床索引 abedFlagTime，
				上床离床索引数组长度 aftLen

Output:         睡眠质量曲线 sleepCurve，
				上床离床索引 abedFlagTime

Return:         无

Others:         无

*******************************************************************/

void CSleepCurve::ResultCopy(double *sleepCurve, int scLen, int *abedFlagTime, int aftLen)
{
	/* 若存在无效数据，处理无效段*/
	if (m_validDataLen != m_scLenAll)
	{
		for (int i = m_validDataLen; i < m_scLenAll; ++i)
		{
			m_sleepCurveAll[i] = 4.0;
		}
	}

	for (int i = 0, k = m_cntStartIndex; (i < scLen) && (k < m_scLenAll); ++i, ++k)
	{
		sleepCurve[i] = m_sleepCurveAll[k];
	}

	for (int i = 0; i < aftLen; ++i)
	{
		abedFlagTime[i] = INVALID_DATA_VALUE;
	}

	if (m_bedInfo.empty())
	{
		return;
	}

	for (size_t i = 0; i < m_bedInfo.size(); ++i)
	{
		m_bedInfo[i].startBed -= m_cntStartIndex;
		
		if (INVALID_DATA_VALUE == m_bedInfo[i].finishBed)
		{
			break;
		}

		m_bedInfo[i].finishBed -= m_cntStartIndex;
	}

	int indexFlag = 0;
	for (size_t i = 0; i < m_bedInfo.size(); ++i)
	{
		if ((m_bedInfo[i].finishBed < 0) && (m_bedInfo[i].finishBed != INVALID_DATA_VALUE))
		{
			continue;
		}

		if (0 == indexFlag)
		{
			if (m_bedInfo[i].startBed >= 0)
			{
				abedFlagTime[indexFlag++] = ABED_START;
				abedFlagTime[indexFlag++] = m_bedInfo[i].startBed;
				abedFlagTime[indexFlag++] = m_bedInfo[i].finishBed;
			}
			else
			{
				abedFlagTime[indexFlag++] = ABED_END;
				abedFlagTime[indexFlag++] = m_bedInfo[i].finishBed;
			}

			continue;
		}

		abedFlagTime[indexFlag++] = m_bedInfo[i].startBed;
		if (indexFlag == aftLen)
		{
			break;
		}

		abedFlagTime[indexFlag++] = m_bedInfo[i].finishBed;
		if (indexFlag == aftLen)
		{
			break;
		}
	}

	if (NULL != m_sleepCurveAll)
	{
		delete[] m_sleepCurveAll;
		m_sleepCurveAll = NULL;
	}

	m_turnInfo.clear();
	m_bedInfo.clear();

}

/*****************************************************************

Function:       CalcSleepQualityTime()

Description:    根据睡眠质量曲线，计算各睡眠状态的时间

Calls:          单段睡眠时间计算函数：CalcSleepQualityTimeS()

Input:          睡眠质量曲线 sleepCurve,
				睡眠质量曲线长度 scLen，
				上床离床索引 abedFlagTime，
				上床离床索引数组长度 aftLen,
				睡眠状态时间 sqTime

Output:         睡眠状态时间 sqTime

Return:         无

Others:         无

*******************************************************************/

void CSleepCurve::CalcSleepQualityTime(const double *sleepCurve, int scLen, int *abedFlagTime, int aftLen, SleepQualityTime &sqTime)
{
	sqTime.awake 		= 0;
	sqTime.lightSleep 	= 0;
	sqTime.midSleep 	= 0;
	sqTime.deepSleep 	= 0;

	if (INVALID_DATA_VALUE == abedFlagTime[0])
	{
		return;
	}

	int indexFlag = 0;
	if (ABED_END == abedFlagTime[indexFlag++])
	{
		CalcSleepQualityTimeS(sleepCurve, 0, abedFlagTime[indexFlag], sqTime);
	}

	int start;
	int end;
	while (1)
	{
		if ((indexFlag == aftLen) || (INVALID_DATA_VALUE == abedFlagTime[indexFlag]))
		{
			break;
		}

		start = abedFlagTime[indexFlag++];
		if ((indexFlag == aftLen) || (INVALID_DATA_VALUE == abedFlagTime[indexFlag]))
		{
			end = m_validDataLen - m_cntStartIndex;
			CalcSleepQualityTimeS(sleepCurve, start, end, sqTime);
			break;
		}

		end = abedFlagTime[indexFlag++];

		CalcSleepQualityTimeS(sleepCurve, start, end, sqTime);
	}

}

/*****************************************************************

Function:       CalcSleepQualityTimeS()

Description:    根据睡眠质量曲线，计算单时间段内各睡眠状态的时间

Calls:          无

Input:          睡眠质量曲线 sleepCurve,
				起始位置 start，
				终止位置 end,
				睡眠状态时间 sqTime

Output:         睡眠状态时间 sqTime

Return:         无

Others:         无

*******************************************************************/

void CSleepCurve::CalcSleepQualityTimeS(const double *sleepCurve, int start, int end, SleepQualityTime &sqTime)
{
	for (int i = start; i < end; ++i)
	{
		if (sleepCurve[i] <= DEEP_SLEEP_THRESHOLD)
		{
			sqTime.deepSleep += CURVE_POINT_INTERVAL;
		}
		else if (sleepCurve[i] <= MID_SLEEP_THRESHOLD)
		{
			sqTime.midSleep += CURVE_POINT_INTERVAL;
		}
		else if (sleepCurve[i] <= LIGHT_SLEEP_THRESHOLD)
		{
			sqTime.lightSleep += CURVE_POINT_INTERVAL;
		}
		else
		{
			sqTime.awake += CURVE_POINT_INTERVAL;
		}
	}
}

/*****************************************************************

Function:       GetTurnAndBedInfo()

Description:    根据睡眠数据，获取睡眠曲线点上对应的翻身状态和
				上床离床状态

Calls:          无

Input:          睡眠数据 sleepData,
				睡眠数据长度 sdLen

Output:         无

Return:         无

Others:         无

*******************************************************************/

void CSleepCurve::GetTurnAndBedInfo(const unsigned char *sleepData, int sdLen)
{
	m_turnInfo.clear();

	short cntTurn;
	short preAbedFlag;
	short curAbedFlag;
	int time;
	bool isAbed;

	TurnInfo turnInfoTemp;
	BedInfo bedInfoTemp;

	/************************************************************************
	* 统计上床和下床的时间位置，对于小于阈值的上床时间，按离床处理
	* 统计翻身的次数和翻身时间位置
	************************************************************************/

	time = 0;
	preAbedFlag = curAbedFlag = NON_ABED;
	isAbed = false;

	for (int i = 0; i < sdLen; ++i, time += THREE_MINUTE_LEN)
	{
		/* 判断有效数据 */
		if (0xff == sleepData[i])
		{
			break;
		}

		curAbedFlag = 0xf0;
		curAbedFlag &= sleepData[i];
		curAbedFlag >>= 4;

		/*********************************************************
		* 上床的标记变化如下：
		* NON_ABED TO ABED
		* NON_ABED TO ABED_START
		* ABED_END TO ABED
		* ABED_END TO ABED_START
		*********************************************************/

		if (   ((NON_ABED == preAbedFlag) && (ABED == curAbedFlag))
			|| ((NON_ABED == preAbedFlag) && (ABED_START == curAbedFlag))
			|| ((ABED_END == preAbedFlag) && (ABED == curAbedFlag))
			|| ((ABED_END == preAbedFlag) && (ABED_START == curAbedFlag)))
		{
			bedInfoTemp.startBed = time;
			isAbed = true;
		}

		/*********************************************************
		* 下床的标记变化如下：
		* ABED_START TO NON_ABED
		* ABED_START TO ABED_END
		* ABED TO NON_ABED
		* ABED TO ABED_END
		*********************************************************/

		else if ( ((ABED_START == preAbedFlag) && (NON_ABED == curAbedFlag))
			   || ((ABED_START == preAbedFlag) && (ABED_END == curAbedFlag))
			   || ((ABED == preAbedFlag) && (NON_ABED == curAbedFlag))
			   || ((ABED == preAbedFlag) && (ABED_END == curAbedFlag)))
		{
			isAbed = false;

			if (time - bedInfoTemp.startBed >= ABED_MIN_LEN)
			{
				bedInfoTemp.finishBed = time;
				m_bedInfo.push_back(bedInfoTemp);
			}
			else
			{
				/* 若上床时间小于阈值，则将之前上床范围统计的翻身次数清零 */
				while (!m_turnInfo.empty())
				{
					size_t size = m_bedInfo.size();
					if (m_turnInfo[size - 1].time < bedInfoTemp.startBed)
					{
						break;
					}

					m_turnInfo.pop_back();
				}
			}
		}

		preAbedFlag = curAbedFlag;

		cntTurn = 0x0f;
		cntTurn &= sleepData[i];
		if (isAbed && (0 != cntTurn))
		{
			cntTurn = (cntTurn > MAX_CNT_TURN_OVER) ? MAX_CNT_TURN_OVER : cntTurn;
			turnInfoTemp.cnt 	= cntTurn;
			turnInfoTemp.time 	= time;
			m_turnInfo.push_back(turnInfoTemp);
		}
	}

	m_validDataLen = time;

	/* 若最后为上床，但未出现下床，则下床部分放入无效数据 */
	if (isAbed)
	{
		bedInfoTemp.finishBed = INVALID_DATA_VALUE;
		m_bedInfo.push_back(bedInfoTemp);
	}
}

/*****************************************************************

Function:       InitCurve()

Description:    初始化睡眠曲线，离床状态下为4.0，在床状态为0.0

Calls:          无

Input:          无

Output:         无

Return:         无

Others:         无

*******************************************************************/

void CSleepCurve::InitCurve()
{
	if ((NULL == m_sleepCurveAll) || (m_scLenAll <= 0))
	{
		return;
	}

	for (int i = 0; i < m_scLenAll; ++i)
	{
		m_sleepCurveAll[i] = 0.0;
	}

	if (m_bedInfo.empty())
	{
		return;
	}

	size_t size = m_bedInfo.size();
	for (size_t i = 0; i < size; ++i)
	{
		size_t begin 	= (i == 0) ? 0 : m_bedInfo[i - 1].finishBed;
		size_t end 		= m_bedInfo[i].startBed;

		for (size_t k = begin; k < end; ++k)
		{
			m_sleepCurveAll[k] = 4.0;
		}
	}

	if (INVALID_DATA_VALUE == m_bedInfo[size-1].finishBed)
	{
		return;
	}

	for (size_t k = m_bedInfo[size-1].finishBed; k < m_scLenAll; ++k)
	{
		m_sleepCurveAll[k] = 4.0;
	}
}

/*****************************************************************

Function:       CalcCntTurnOver()

Description:    以睡眠曲线点为准，在给点时间范围内的翻身次数

Calls:          无

Input:          开始位置 begin, 结束位置 end

Output:         无

Return:         翻身次数

Others:         无

*******************************************************************/

int CSleepCurve::CalcCntTurnOver(int begin, int end)
{
	int cntTurnOver = 0;
	for (size_t i = 0; i < m_turnInfo.size(); ++i)
	{
		if (m_turnInfo[i].time < begin)
		{
			continue;
		}
		else if (m_turnInfo[i].time >= end)
		{
			break;
		}

		cntTurnOver += m_turnInfo[i].cnt;
	}

	return cntTurnOver;
}

/*****************************************************************

Function:       Spline()

Description:    进行三次样条插值（网上查抄代码）

Calls:          无

Input:          已知数据x坐标序列 x,
				已知数据y坐标序列 y,
				已知数据序列的长度 n,
				第一点二阶导数值 ddy1,
				最后一个点二阶导数值 ddyn,
				插值数据x坐标序列 t，
				插值数据序列的长度 m,
				插值数据y坐标序列 z

Output:         插值结果 z

Return:         无

Others:         无

*******************************************************************/

void CSleepCurve::Spline(double x[], double y[], int n, double ddy1, double ddyn, double t[], int m, double z[])
{
	int i, j;
	double h0, h1, alpha, beta, *s, *dy;

	s = new double[n];
	if (NULL == s)
	{
		return;
	}

	dy = new double[n];
	if (NULL == dy)
	{
		delete[] s;
		s = NULL;

		return;
	}

	dy[0] = -0.5;
	h0 = x[1] - x[0];

	s[0] = 3.0*(y[1] - y[0]) / (2.0*h0) - ddy1*h0 / 4.0;
	for (j = 1; j <= n - 2; j++)
	{
		h1 = x[j + 1] - x[j];
		alpha = h0 / (h0 + h1);
		beta = (1.0 - alpha)*(y[j] - y[j - 1]) / h0;
		beta = 3.0*(beta + alpha*(y[j + 1] - y[j]) / h1);
		dy[j] = -alpha / (2.0 + (1.0 - alpha)*dy[j - 1]);
		s[j] = (beta - (1.0 - alpha)*s[j - 1]);
		s[j] = s[j] / (2.0 + (1.0 - alpha)*dy[j - 1]);
		h0 = h1;
	}
	dy[n - 1] = (3.0*(y[n - 1] - y[n - 2]) / h1 + ddyn*h1 / 2.0 - s[n - 2]) / (2.0 + dy[n - 2]);
	for (j = n - 2; j >= 0; j--)        dy[j] = dy[j] * dy[j + 1] + s[j];
	for (j = 0; j <= n - 2; j++)        s[j] = x[j + 1] - x[j];
	for (j = 0; j <= m - 1; j++)
	{
		if (t[j] >= x[n - 1]) i = n - 2;
		else
		{
			i = 0;
			while (t[j] > x[i + 1]) i = i + 1;
		}
		h1 = (x[i + 1] - t[j]) / s[i];
		h0 = h1*h1;
		z[j] = (3.0*h0 - 2.0*h0*h1)*y[i];
		z[j] = z[j] + s[i] * (h0 - h0*h1)*dy[i];
		h1 = (t[j] - x[i]) / s[i];
		h0 = h1*h1;
		z[j] = z[j] + (3.0*h0 - 2.0*h0*h1)*y[i + 1];
		z[j] = z[j] - s[i] * (h0 - h0*h1)*dy[i + 1];
	}

	delete[] s;
	delete[] dy;

	s = NULL;
	dy = NULL;
}