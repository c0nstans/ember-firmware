#ifndef HARDWAREFACTORY_H
#define	HARDWAREFACTORY_H

#include <memory>

class IResource;
class I_I2C_Device;

typedef std::unique_ptr<I_I2C_Device> I2C_DevicePtr;
typedef std::unique_ptr<IResource> ResourcePtr;

namespace HardwareFactory
{
I2C_DevicePtr CreateMotorControllerI2cDevice();
I2C_DevicePtr CreateFrontPanelI2cDevice();
I2C_DevicePtr CreateProjectorI2cDevice();
ResourcePtr   CreateMotorControllerInterruptResource();
ResourcePtr   CreateFrontPanelInterruptResource();
};


#endif  // HARDWAREFACTORY_H
