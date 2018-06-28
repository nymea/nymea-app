#ifndef TAG_H
#define TAG_H

#include <QObject>

class Tag : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString deviceId READ deviceId CONSTANT)
    Q_PROPERTY(QString ruleId READ ruleId CONSTANT)
    Q_PROPERTY(QString tagId READ tagId CONSTANT)
    Q_PROPERTY(QString value READ value NOTIFY valueChanged)

public:
    explicit Tag(const QString &tagId, const QString &value, QObject *parent = nullptr);

    QString deviceId() const;
    void setDeviceId(const QString &deviceId);

    QString ruleId() const;
    void setRuleId(const QString &ruleId);

    QString tagId() const;

    QString value() const;
    void setValue(const QString &value);

signals:
    void valueChanged();

private:
    QString m_deviceId;
    QString m_ruleId;
    QString m_tagId;
    QString m_value;
};

#endif // TAG_H
