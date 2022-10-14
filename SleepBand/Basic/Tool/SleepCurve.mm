/********************************************************************************************
File:			SleepCurve.cpp

Author:			Wang Xiang

Date:			2018-07-25

Description:	����˯�����ߵļ��㣬ͨ������������ϴ��봲��Ϣ����˯������
**********************************************************************************************/

#include "SleepCurve.h"

const short CURVE_POINT_INTERVAL	= 10;	/* ÿ����֮����10�� */

const short ONE_MINUTE_LEN 			= 60 / CURVE_POINT_INTERVAL;		/* 1���� */
const short TWO_MINUTE_LEN 			= (2 * 60) / CURVE_POINT_INTERVAL;	/* 2���� */
const short THREE_MINUTE_LEN 		= (3 * 60) / CURVE_POINT_INTERVAL;	/* 3���� */
const short FIVE_MINUTE_LEN 		= (5 * 60) / CURVE_POINT_INTERVAL;	/* 5���� */
const short FIFTEEN_MINUTE_LEN 		= (15 * 60) / CURVE_POINT_INTERVAL;	/* 15���� */
const short THIRTY_MINUTE_LEN 		= (30 * 60) / CURVE_POINT_INTERVAL;	/* 30���� */
const short TWENTY_MINUTE_LEN 		= (20 * 60) / CURVE_POINT_INTERVAL;	/* 20���� */
const short TEN_MINUTE_LEN 			= (10 * 60) / CURVE_POINT_INTERVAL;	/* 10���� */

const short ABED_MIN_LEN 			= FIFTEEN_MINUTE_LEN;

const short MAX_CNT_TURN_OVER 		= 3;	/* 3����������������*/

const int INVALID_DATA_VALUE		= -65536;

const double EPSINON 				= 0.00000001;

struct Axis 
{
	int x;
	double y;
};

enum AbedStatus
{
	NON_ABED,		/* �봲״̬ */
	ABED_START,		/* �ϴ�״̬ */
	ABED,			/* �ڴ�״̬ */
	ABED_END		/* ��״̬ */
};

/*****************************************************************

Function:       CSleepCurve()

Description:    ���캯��

Calls:          ��

Input:          ��

Output:         ��

Return:         ��

Others:         ��

*******************************************************************/

CSleepCurve::CSleepCurve()
{
	m_sleepCurveAll = NULL;

	m_turnInfo.clear();
	m_bedInfo.clear();
}

/*****************************************************************

Function:       ~CSleepCurve()

Description:    ��������

Calls:          ��

Input:          ��

Output:         ��

Return:         ��

Others:         ��

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

Description:    ����˯����������

Calls:          ��ȡ����״̬���ڴ��봲״̬������GetTurnAndBedInfo()
				��ʼ�����ߺ�����InitCurve()
				���ݷ��������������ֵ������SetValue()
				��ֵ������Interpolation()
				����˯������ʱ�亯����CalcSleepQualityTime()
				˯�߽�����ƺ�����ResultCopy()

Input:          ˯������ sleepData,
				˯�����ݳ��� sdLen,
				˯���������� sleepCurve,
				˯���������߳��� scLen
				ͳ�ƿ�ʼ��� cntStartIndex
				�ϴ����봲��� abedFlagTime
				�ϴ��봲������鳤�� aftLen


Output:         ˯���������� sleepCurve,
				˯������ʱ��ͳ�� sqTime
				�ϴ����봲��� abedFlagTime


Return:         ��

Others:         ��

******************************************************************************/

void CSleepCurve::CalcSleepCurve(
	const unsigned char *sleepData,		/* ˯������ */
	int sdLen,							/* ˯�����ݳ��� */
	double *sleepCurve,					/* ˯���������� */
	int scLen,							/* ˯���������ݳ��� */
	int cntStartIndex,					/* ͳ�ƿ�ʼ��� */
	int *abedFlagTime,					/* �ϴ����봲��ǣ���˯����������±� */
	int aftLen,							/* �ϴ��봲������鳤�� */
	SleepQualityTime &sqTime			/* ��˯������ʱ��ͳ�� */
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

Description:    ���ݷ���������趨˯�������ϸ�ʱ����ֵ

Calls:          ����һ��ʱ���ڵķ������������CalcCntTurnOver()

Input:          ��

Output:         ��

Return:         ��

Others:         ��

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

	/* 2018-09-27 ����ȫ���޷������� */
	if (turnInfo.empty())
	{
		if (endSeg == INVALID_DATA_VALUE)
		{
			/* 5����ǳ˯��10������˯��15������˯*/
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
	/* 2018-09-27 ���½���*/
	
	/* Ѱ�ҷ���������30���ӵ�λ�õ� */
	std::vector<int> deepSleepPos;
	deepSleepPos.clear();

	std::vector<int> midSleepPos;
	midSleepPos.clear();

	std::vector<int> lightSleepPos;
	lightSleepPos.clear();

	int sleepBegin = 0;

	/* �����˯�����ж�����˯�� */
	for (size_t i = 1; i < turnInfo.size(); ++i)
	{
		if (turnInfo[i].time - turnInfo[i - 1].time > THIRTY_MINUTE_LEN)
		{
			deepSleepPos.push_back(turnInfo[i - 1].time + THIRTY_MINUTE_LEN);
			midSleepPos.push_back(turnInfo[i - 1].time + TWENTY_MINUTE_LEN);
			lightSleepPos.push_back(turnInfo[i - 1].time + TEN_MINUTE_LEN);

			/* ���˯�߽�ֹ�� */
			if (turnInfo[i].time - *(deepSleepPos.rbegin()) - TEN_MINUTE_LEN > 0)
			{
				m_sleepCurveAll[turnInfo[i].time - TEN_MINUTE_LEN] = 1.0;
			}
		}

		/* ��˯ʱ�� */
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
	* �����������Σ� ����ǳ��˯�� 
	* �����������Σ� �����ж�˯��
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

	/* ��˯ʱ������ */
	for (int i = startSeg; i < sleepBegin; ++i)
	{
		m_sleepCurveAll[i] = 4.0;
	}

	/* ����20�����޷�����״̬�ı� */
	const double DELTA_VALUE 	= 0.6;
	const double MIN_VALUE 		= 0.4;

	for (size_t i = 1; i < turnInfo.size(); ++i)
	{
		if (turnInfo[i].time - turnInfo[i - 1].time <= TWENTY_MINUTE_LEN)
		{
			continue;
		}

		/* λ�õ�δ���޸� */
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

	/* 2019-01-25, ��֮ǰ���Ǵη����ʵ�����ǰ�ƶ�������������Ͻ���ܶ��� */
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

Description:    ��˯�������ϵĵ���в�ֵ���Լ������������

Calls:          ����һ��ʱ���ڵķ������������CalcCntTurnOver()
				��������������Ϻ�����Spline()

Input:          ��

Output:         ��

Return:         ��

Others:         ��

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

	/* ����������ֵ */
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

	/* �������һ�ν������� */
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

Description:    ��ͳ����������˯����������

Calls:          ��

Input:          ˯���������� sleepCurve,
				˯���������߳��� scLen��
				�ϴ��봲���� abedFlagTime��
				�ϴ��봲�������鳤�� aftLen

Output:         ˯���������� sleepCurve��
				�ϴ��봲���� abedFlagTime

Return:         ��

Others:         ��

*******************************************************************/

void CSleepCurve::ResultCopy(double *sleepCurve, int scLen, int *abedFlagTime, int aftLen)
{
	/* ��������Ч���ݣ�������Ч��*/
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

Description:    ����˯���������ߣ������˯��״̬��ʱ��

Calls:          ����˯��ʱ����㺯����CalcSleepQualityTimeS()

Input:          ˯���������� sleepCurve,
				˯���������߳��� scLen��
				�ϴ��봲���� abedFlagTime��
				�ϴ��봲�������鳤�� aftLen,
				˯��״̬ʱ�� sqTime

Output:         ˯��״̬ʱ�� sqTime

Return:         ��

Others:         ��

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

Description:    ����˯���������ߣ����㵥ʱ����ڸ�˯��״̬��ʱ��

Calls:          ��

Input:          ˯���������� sleepCurve,
				��ʼλ�� start��
				��ֹλ�� end,
				˯��״̬ʱ�� sqTime

Output:         ˯��״̬ʱ�� sqTime

Return:         ��

Others:         ��

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

Description:    ����˯�����ݣ���ȡ˯�����ߵ��϶�Ӧ�ķ���״̬��
				�ϴ��봲״̬

Calls:          ��

Input:          ˯������ sleepData,
				˯�����ݳ��� sdLen

Output:         ��

Return:         ��

Others:         ��

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
	* ͳ���ϴ����´���ʱ��λ�ã�����С����ֵ���ϴ�ʱ�䣬���봲����
	* ͳ�Ʒ���Ĵ����ͷ���ʱ��λ��
	************************************************************************/

	time = 0;
	preAbedFlag = curAbedFlag = NON_ABED;
	isAbed = false;

	for (int i = 0; i < sdLen; ++i, time += THREE_MINUTE_LEN)
	{
		/* �ж���Ч���� */
		if (0xff == sleepData[i])
		{
			break;
		}

		curAbedFlag = 0xf0;
		curAbedFlag &= sleepData[i];
		curAbedFlag >>= 4;

		/*********************************************************
		* �ϴ��ı�Ǳ仯���£�
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
		* �´��ı�Ǳ仯���£�
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
				/* ���ϴ�ʱ��С����ֵ����֮ǰ�ϴ���Χͳ�Ƶķ���������� */
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

	/* �����Ϊ�ϴ�����δ�����´������´����ַ�����Ч���� */
	if (isAbed)
	{
		bedInfoTemp.finishBed = INVALID_DATA_VALUE;
		m_bedInfo.push_back(bedInfoTemp);
	}
}

/*****************************************************************

Function:       InitCurve()

Description:    ��ʼ��˯�����ߣ��봲״̬��Ϊ4.0���ڴ�״̬Ϊ0.0

Calls:          ��

Input:          ��

Output:         ��

Return:         ��

Others:         ��

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

Description:    ��˯�����ߵ�Ϊ׼���ڸ���ʱ�䷶Χ�ڵķ������

Calls:          ��

Input:          ��ʼλ�� begin, ����λ�� end

Output:         ��

Return:         �������

Others:         ��

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

Description:    ��������������ֵ�����ϲ鳭���룩

Calls:          ��

Input:          ��֪����x�������� x,
				��֪����y�������� y,
				��֪�������еĳ��� n,
				��һ����׵���ֵ ddy1,
				���һ������׵���ֵ ddyn,
				��ֵ����x�������� t��
				��ֵ�������еĳ��� m,
				��ֵ����y�������� z

Output:         ��ֵ��� z

Return:         ��

Others:         ��

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