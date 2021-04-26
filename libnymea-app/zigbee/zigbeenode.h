#ifndef ZIGBEENODE_H
#define ZIGBEENODE_H

#include <QUuid>
#include <QObject>

class ZigbeeNode : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid networkUuid READ networkUuid CONSTANT)


public:
    explicit ZigbeeNode(QUuid networkUuid, QObject *parent = nullptr);

    QUuid networkUuid() const;

    QString ieeeAddress() const;
    void setIeeeAddress(const QString &ieeeAddress);

signals:

private:
    QUuid m_networkUuid;
    QString m_ieeeAddress;
};

#endif // ZIGBEENODE_H
