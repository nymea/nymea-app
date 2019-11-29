#ifndef TAG_H
#define TAG_H

#include <QObject>
#include <QUuid>

class Tag : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid deviceId READ deviceId CONSTANT)
    Q_PROPERTY(QUuid ruleId READ ruleId CONSTANT)
    Q_PROPERTY(QString tagId READ tagId CONSTANT)
    Q_PROPERTY(QString value READ value NOTIFY valueChanged)

public:
    explicit Tag(const QString &tagId, const QString &value, QObject *parent = nullptr);

    QUuid deviceId() const;
    void setDeviceId(const QUuid &deviceId);

    QUuid ruleId() const;
    void setRuleId(const QUuid &ruleId);

    QString tagId() const;

    QString value() const;
    void setValue(const QString &value);

signals:
    void valueChanged();

private:
    QUuid m_deviceId;
    QUuid m_ruleId;
    QString m_tagId;
    QString m_value;
};

#endif // TAG_H
