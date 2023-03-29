#include "qhashqml.h"

QHashQml::QHashQml(QObject *parent)
    : QObject{parent}
{

}

void QHashQml::insert(int key, const QVariant &value)
{
    m_hash.insert(key, value);
}

bool QHashQml::contains(int key)
{
    return m_hash.contains(key);
}

QVariant QHashQml::value(int key)
{
    return m_hash.value(key);
}
