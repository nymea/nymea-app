#ifndef REPOSITORY_H
#define REPOSITORY_H

#include <QObject>

class Repository : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString displayName READ displayName CONSTANT)
    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged)

public:
    explicit Repository(const QString &id, const QString &displayName, QObject *parent = nullptr);

    QString id() const;
    QString displayName() const;

    bool enabled() const;
    void setEnabled(bool enabled);

signals:
    void enabledChanged();

private:
    QString m_id;
    QString m_displayName;
    bool m_enabled = false;
};

#endif // REPOSITORY_H
