#ifndef TAGS_H
#define TAGS_H

#include <QAbstractListModel>

class Tag;

class Tags: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleDeviceId,
        RoleRuleId,
        RoleTagId,
        RoleValue
    };
    Q_ENUM(Roles)

    explicit Tags(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addTag(Tag *tag);
    void addTags(QList<Tag*> tags);
    void removeTag(Tag *tag);

    Tag* get(int index) const;

    Q_INVOKABLE Tag* findDeviceTag(const QUuid &deviceId, const QString &tagId) const;
    Q_INVOKABLE Tag* findRuleTag(const QString &ruleId, const QString &tagId) const;

    void clear();

signals:
    void countChanged();

private slots:
    void tagValueChanged();

private:
    QList<Tag*> m_list;
};

#endif // TAGS_H
