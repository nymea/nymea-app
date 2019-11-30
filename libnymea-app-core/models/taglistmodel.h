#ifndef TAGLISTMODEL_H
#define TAGLISTMODEL_H

#include <QAbstractListModel>

class TagsProxyModel;
class Tag;

class TagListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(TagsProxyModel* tagsProxy READ tagsProxy WRITE setTagsProxy NOTIFY tagsProxyChanged)
public:
    enum Roles {
        RoleTagId,
        RoleValue
    };
    explicit TagListModel(QObject *parent = nullptr);

    TagsProxyModel* tagsProxy() const;
    void setTagsProxy(TagsProxyModel* tagsProxy);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE bool containsId(const QString &tagId);
    Q_INVOKABLE bool containsValue(const QString &tagValue);

signals:
    void countChanged();
    void tagsProxyChanged();

private slots:
    void update();

private:
    TagsProxyModel *m_tagsProxy = nullptr;

    QList<Tag*> m_list;
};

#endif // TAGLISTMODEL_H
