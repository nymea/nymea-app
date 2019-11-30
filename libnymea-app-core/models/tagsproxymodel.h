#ifndef TAGSPROXYMODEL_H
#define TAGSPROXYMODEL_H

#include <QSortFilterProxyModel>

class Tag;
class Tags;

class TagsProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(Tags* tags READ tags WRITE setTags NOTIFY tagsChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QString filterTagId READ filterTagId WRITE setFilterTagId NOTIFY filterTagIdChanged)
    Q_PROPERTY(QString filterDeviceId READ filterDeviceId WRITE setFilterDeviceId NOTIFY filterDeviceIdChanged)
    Q_PROPERTY(QString filterRuleId READ filterRuleId WRITE setFilterRuleId NOTIFY filterRuleIdChanged)

public:
    explicit TagsProxyModel(QObject *parent = nullptr);

    Tags* tags() const;
    void setTags(Tags* tags);

    QString filterTagId() const;
    void setFilterTagId(const QString &filterTagId);

    QString filterDeviceId() const;
    void setFilterDeviceId(const QString &filterDeviceId);

    QString filterRuleId() const;
    void setFilterRuleId(const QString &filterRuleId);

    Q_INVOKABLE Tag* get(int index) const;
    Q_INVOKABLE Tag* findTag(const QString &tagId) const;

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

signals:
    void tagsChanged();
    void filterTagIdChanged();
    void filterDeviceIdChanged();
    void filterRuleIdChanged();
    void groupSameTagsChanged();
    void countChanged();

private:
    Tags *m_tags = nullptr;
    QString m_filterTagId;
    QString m_filterDeviceId;
    QString m_filterRuleId;
};

#endif // TAGSPROXYMODEL_H
