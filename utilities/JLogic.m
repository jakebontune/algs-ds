// 
// JLogic.m
//

#import "JLogic.h"

#pragma mark - nebang integer

int iNebang(int num) {
	return num < 0 ? 0 : num;
}

int iNebangDifference(int minuend, int subtrahend) {
	return subtrahend > minuend ? 0 : (minuend - subtrahend);
}

int iNebangLimit(int num, int limit) {
	return num > limit ? 0 : num;
}

#pragma mark - nebang unsigned integer

uint uNebangDifference(uint minuend, uint subtrahend) {
	return subtrahend > minuend ? 0 : (minuend - subtrahend);
}

uint uNebangLimit(uint num, uint limit) {
	return num > limit ? 0 : num;
}

#pragma mark - nebang float

float fNebang(float num) {
	return num < 0.0f ? 0.0f : num;
}

float fNebangDifference(float minuend, float subtrahend) {
	return subtrahend > minuend ? 0.0f : (minuend - subtrahend);
}

float fNebangLimit(float num, float limit) {
	return num > limit ? 0.0f : num;
}

#pragma mark - nebang double

double dNebang(double num) {
	return num < 0.0 ? 0.0 : num;
}

double dNebangDifference(double minuend, double subtrahend) {
	return subtrahend > minuend ? 0.0 : (minuend - subtrahend);
}

double dNebangLimit(double num, double limit) {
	return num > limit ? 0.0 : num;
}