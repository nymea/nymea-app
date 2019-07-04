#ifndef BROWSERITEM_H
#define BROWSERITEM_H

#include <QObject>
#include <QUuid>

class BrowserItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QString displayName READ displayName CONSTANT)
    Q_PROPERTY(QString description READ description CONSTANT)
    Q_PROPERTY(QString thumbnail READ thumbnail CONSTANT)
    Q_PROPERTY(bool executable READ executable CONSTANT)
    Q_PROPERTY(bool browsable READ browsable CONSTANT)

public:
    explicit BrowserItem(const QString &id, QObject *parent = nullptr);

    QString id() const;

    QString displayName() const;
    void setDisplayName(const QString &displayName);

    QString description() const;
    void setDescription(const QString &description);

    QString thumbnail() const;
    void setThumbnail(const QString &thumbnail);

    bool executable() const;
    void setExecutable(bool executable);

    bool browsable() const;
    void setBrowsable(bool browsable);

private:
    QString m_id;
    QString m_displayName;
    QString m_description;
    QString m_thumbnail;
    bool m_executable = false;
    bool m_browsable = false;
};

#endif // BROWSERITEM_H
