#ifndef ANDROIDBINDER_H
#define ANDROIDBINDER_H

#include <QAndroidBinder>

#include "engine.h"

class AndroidBinder : public QAndroidBinder
{
public:
    explicit AndroidBinder(Engine *engine);

    bool onTransact(int code, const QAndroidParcel &data, const QAndroidParcel &reply, QAndroidBinder::CallType flags) override;

private:
    Engine *m_engine = nullptr;
};

#endif // ANDROIDBINDER_H
