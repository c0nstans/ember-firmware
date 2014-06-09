/* 
 * File:   PrinterStatus.h
 * Author: greener
 *
 * Created on April 1, 2014, 3:09 PM
 */

#ifndef PRINTERSTATUS_H
#define	PRINTERSTATUS_H

#include <stddef.h>

/// the possible changes in state
enum StateChange
{
    NoChange,
    Entering,
    Leaving,
};

class PrinterStatus
{
public:    
    const char* _state;
    StateChange _change;
    bool _isError;
    int _errorCode;
    char* _errorMessage;
    int _numLayers;
    int _currentLayer;
    int _estimatedSecondsRemaining;
    char* _jobName;  // e.g. base file name for PNGs
    float _temperature;
    
    PrinterStatus() :
    _state(NULL),
    _change(NoChange),
    _isError(false),
    _errorCode(0),
    _errorMessage(NULL),
    _numLayers(0),
    _currentLayer(0),
    _estimatedSecondsRemaining(0),
    _jobName(NULL),
    _temperature(0.0f)
    {}
};

#endif	/* PRINTERSTATUS_H */
