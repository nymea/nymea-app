#ifndef QHASHQML_H
#define QHASHQML_H

#include <QObject>
#include <QHash>
#include <QVariant>

class QHashQml : public QObject
{
    Q_OBJECT
public:
    explicit QHashQml(QObject *parent = nullptr);

    Q_INVOKABLE void insert(int key, const QVariant &value);
    Q_INVOKABLE bool contains(int key);
    Q_INVOKABLE QVariant value(int key);


private:
    QHash<int, QVariant> m_hash;
};

#endif // QHASHQML_H
