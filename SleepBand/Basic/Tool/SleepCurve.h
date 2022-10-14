/**************************************************************************************************************
File:			SleepCurve.h

Author:			Wang Xiang

Date:			2018-07-25

Description:	进行睡眠曲线的计算，通过翻身次数和上床离床信息计算睡眠曲线

				主函数入口为 CalcSleepCurve(
											const unsigned char *sleepData,		
											int sdLen,
											double *sleepCurve,
											int scLen,
											int cntStartIndex,
											int *abedFlagTime,
											int aftLen,
											SleepQualityTime &sqTime
											)
									
				sleepData:		输入的睡眠数据，高四位为上床离床信息，低四位为翻身信息，3分钟一个点
				sdLen:			睡眠数据的长度
				sleepCurve:		输出的睡眠曲线，10秒钟一个点，需要先申请好内存再调用函数
				scLen:			睡眠曲线的长度, 理论上，scLen = 3 * 6 * sdLen
				cntStartIndex:	统计开始时间
				abedFlagTime:	上床和离床的标记索引，对应睡眠质量曲线
				aftLen：		上床离床索引数组长度
				sqTime:			输出的睡眠状态时间，包含清醒、浅睡、中睡和深睡4个状态
*******************************************************************************************************************/

#pragma once

#include <iostream>
#include <vector>

const double MAX_CURVE_VALUE = 4.0;		/* 睡眠曲线最大值 */
const double MIN_CURVE_VALUE = 0.1;		/* 睡眠曲线最小值 */


/************************************************************************
*	睡眠质量阈值
*	清醒：(3.9, 4.0]
*	浅睡：(2.5, 3.9]
*	中睡：(1.5, 2.5]
*	深睡：[0.1, 1.5]
************************************************************************/

const double LIGHT_SLEEP_THRESHOLD		= 3.9;
const double MID_SLEEP_THRESHOLD		= 2.5;
const double DEEP_SLEEP_THRESHOLD		= 1.5;

struct SleepQualityTime 
{
	int awake;			/* 清醒状态总时间，单位：秒 */
	int lightSleep;		/* 浅睡状态总时间，单位：秒 */
	int midSleep;		/* 中睡状态总时间，单位：秒 */
	int deepSleep;		/* 深睡状态总时间，单位：秒 */
};

struct TurnInfo 
{
	short cnt;
	int time;
};

struct BedInfo 
{
	int startBed;
	int finishBed;
};

class CSleepCurve
{
public:
	CSleepCurve();
	~CSleepCurve();

	void CalcSleepCurve(
		const unsigned char *sleepData,		/* 睡眠数据 */
		int sdLen,							/* 睡眠数据长度 */
		double *sleepCurve,					/* 睡眠曲线数据 */
		int scLen,							/* 睡眠曲线数据长度 */
		int cntStartIndex,					/* 统计开始标记 */
		int *abedFlagTime,					/* 上床和离床标记，在睡眠曲线里的下标 */
		int aftLen,							/* 上床离床标记数组长度 */
		SleepQualityTime &sqTime			/* 各睡眠质量时间统计 */
	);

private:
	void GetTurnAndBedInfo(const unsigned char *sleepData, int sdLen);
	void InitCurve();

	void SetValue(int start, int end);
	void Interpolation();
	void ResultCopy(double *sleepCurve, int scLen, int *abedFlagTime, int aftLen);
	void CalcSleepQualityTime(const double *sleepCurve, int scLen, int *abedFlagTime, int aftLen, SleepQualityTime &sqTime);
	void CalcSleepQualityTimeS(const double *sleepCurve, int start, int end, SleepQualityTime &sqTime);
	int CalcCntTurnOver(int begin, int end);

private:
	void Spline(double x[],                                                                /*x坐标序列*/
		double y[],                                                                /*y坐标序列*/
		int n,                                                                        /*输入数据个数*/
		double ddy1, double ddyn,                                /*第一点和最末点二阶导数*/
		double t[],                                                                /*插值点的x坐标序列*/
		int m,                                                                        /*插值点个数*/
		double z[]                                                                /*差值点的y坐标序列*/
	);

private:
	std::vector<TurnInfo> m_turnInfo;
	std::vector<BedInfo> m_bedInfo;
	double *m_sleepCurveAll;
	int m_scLenAll;
	int m_validDataLen;
	int m_cntStartIndex;
    
};
