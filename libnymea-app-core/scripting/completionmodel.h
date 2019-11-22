#ifndef COMPLETIONMODEL_H
#define COMPLETIONMODEL_H

#include <QAbstractListModel>
#include <QSortFilterProxyModel>

class CompletionModel: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    class Entry {
    public:
        Entry(const QString &text, const QString &displayText, bool addTrailingQuote = false, bool addComment = false)
            : text(text), displayText(displayText), addTrailingQuote(addTrailingQuote), addComment(addComment) {}
        Entry(const QString &text): text(text), displayText(text) {}
        QString text;
        QString displayText;
        bool addTrailingQuote = false;
        bool addComment = false;
    };

    CompletionModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    void update(const QList<Entry> &entries);

    Entry get(int index);

signals:
    void countChanged();

private:
    QList<Entry> m_list;
};

class CompletionProxyModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QString filter READ filter NOTIFY filterChanged)
public:
    CompletionProxyModel(CompletionModel *model, QObject *parent = nullptr);
    CompletionModel::Entry get(int index);

    QString filter() const;
    void setFilter(const QString &filter);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &/*source_parent*/) const override;

signals:
    void countChanged();
    void filterChanged();

private:
    CompletionModel *m_model = nullptr;
    QString m_filter;

};

#endif // COMPLETIONMODEL_H
