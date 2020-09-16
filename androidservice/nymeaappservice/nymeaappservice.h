#ifndef NYMEAAPPSERVICE_H
#define NYMEAAPPSERVICE_H

#include <QAndroidService>

#include "engine.h"

class NymeaAppService : public QAndroidService
{
    Q_OBJECT
public:
    explicit NymeaAppService(int argc, char** argv);

signals:
private:
    Engine *m_engine = nullptr;

};

#endif // NYMEAAPPSERVICE_H
