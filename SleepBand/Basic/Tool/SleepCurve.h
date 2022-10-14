/**************************************************************************************************************
File:			SleepCurve.h

Author:			Wang Xiang

Date:			2018-07-25

Description:	����˯�����ߵļ��㣬ͨ������������ϴ��봲��Ϣ����˯������

				���������Ϊ CalcSleepCurve(
											const unsigned char *sleepData,		
											int sdLen,
											double *sleepCurve,
											int scLen,
											int cntStartIndex,
											int *abedFlagTime,
											int aftLen,
											SleepQualityTime &sqTime
											)
									
				sleepData:		�����˯�����ݣ�����λΪ�ϴ��봲��Ϣ������λΪ������Ϣ��3����һ����
				sdLen:			˯�����ݵĳ���
				sleepCurve:		�����˯�����ߣ�10����һ���㣬��Ҫ��������ڴ��ٵ��ú���
				scLen:			˯�����ߵĳ���, �����ϣ�scLen = 3 * 6 * sdLen
				cntStartIndex:	ͳ�ƿ�ʼʱ��
				abedFlagTime:	�ϴ����봲�ı����������Ӧ˯����������
				aftLen��		�ϴ��봲�������鳤��
				sqTime:			�����˯��״̬ʱ�䣬�������ѡ�ǳ˯����˯����˯4��״̬
*******************************************************************************************************************/

#pragma once

#include <iostream>
#include <vector>

const double MAX_CURVE_VALUE = 4.0;		/* ˯���������ֵ */
const double MIN_CURVE_VALUE = 0.1;		/* ˯��������Сֵ */


/************************************************************************
*	˯��������ֵ
*	���ѣ�(3.9, 4.0]
*	ǳ˯��(2.5, 3.9]
*	��˯��(1.5, 2.5]
*	��˯��[0.1, 1.5]
************************************************************************/

const double LIGHT_SLEEP_THRESHOLD		= 3.9;
const double MID_SLEEP_THRESHOLD		= 2.5;
const double DEEP_SLEEP_THRESHOLD		= 1.5;

struct SleepQualityTime 
{
	int awake;			/* ����״̬��ʱ�䣬��λ���� */
	int lightSleep;		/* ǳ˯״̬��ʱ�䣬��λ���� */
	int midSleep;		/* ��˯״̬��ʱ�䣬��λ���� */
	int deepSleep;		/* ��˯״̬��ʱ�䣬��λ���� */
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
		const unsigned char *sleepData,		/* ˯������ */
		int sdLen,							/* ˯�����ݳ��� */
		double *sleepCurve,					/* ˯���������� */
		int scLen,							/* ˯���������ݳ��� */
		int cntStartIndex,					/* ͳ�ƿ�ʼ��� */
		int *abedFlagTime,					/* �ϴ����봲��ǣ���˯����������±� */
		int aftLen,							/* �ϴ��봲������鳤�� */
		SleepQualityTime &sqTime			/* ��˯������ʱ��ͳ�� */
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
	void Spline(double x[],                                                                /*x��������*/
		double y[],                                                                /*y��������*/
		int n,                                                                        /*�������ݸ���*/
		double ddy1, double ddyn,                                /*��һ�����ĩ����׵���*/
		double t[],                                                                /*��ֵ���x��������*/
		int m,                                                                        /*��ֵ�����*/
		double z[]                                                                /*��ֵ���y��������*/
	);

private:
	std::vector<TurnInfo> m_turnInfo;
	std::vector<BedInfo> m_bedInfo;
	double *m_sleepCurveAll;
	int m_scLenAll;
	int m_validDataLen;
	int m_cntStartIndex;
    
};
