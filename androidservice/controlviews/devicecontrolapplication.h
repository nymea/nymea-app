#ifndef DEVICECONTROLAPPLICATION_H
#define DEVICECONTROLAPPLICATION_H

#include <QApplication>

class DeviceControlApplication : public QApplication
{
    Q_OBJECT
public:
    explicit DeviceControlApplication(int argc, char *argv[]);

};

#endif // DEVICECONTROLAPPLICATION_H
