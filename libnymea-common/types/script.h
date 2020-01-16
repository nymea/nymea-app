#ifndef SCRIPT_H
#define SCRIPT_H

#include <QObject>
#include <QUuid>

class Script : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
public:
    explicit Script(const QUuid &id, QObject *parent = nullptr);

    QUuid id() const;

    QString name() const;
    void setName(const QString &name);

signals:
    void nameChanged();

private:
    QUuid m_id;
    QString m_name;
};

#endif // SCRIPT_H
