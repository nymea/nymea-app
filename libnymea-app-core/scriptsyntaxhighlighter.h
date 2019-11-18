#ifndef SCRIPTSYNTAXHIGHLIGHTER_H
#define SCRIPTSYNTAXHIGHLIGHTER_H

#include <QObject>
#include <QSyntaxHighlighter>
#include <QQuickTextDocument>
#include <QAbstractItemDelegate>
#include <QSortFilterProxyModel>

class ScriptSyntaxHighlighterPrivate;
class CompletionModel;
class CompletionProxyModel;
class Engine;

class ScriptSyntaxHighlighter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(QQuickTextDocument* document READ document WRITE setDocument NOTIFY documentChanged)
    Q_PROPERTY(CompletionProxyModel* completionModel READ completionModel CONSTANT)
    Q_PROPERTY(int cursorPosition READ cursorPosition WRITE setCursorPosition NOTIFY cursorPositionChanged)
public:
    explicit ScriptSyntaxHighlighter(QObject *parent = nullptr);

    Engine* engine() const;
    void setEngine(Engine* engine);

    QQuickTextDocument* document() const;
    void setDocument(QQuickTextDocument *document);

    int cursorPosition() const;
    void setCursorPosition(int cursorPosition);

    CompletionProxyModel* completionModel() const;

public slots:
    void complete(int index);
    void newLine();
    void indent(int from, int to);
    void unindent(int from, int to);
    void closeBlock();

signals:
    void documentChanged();
    void engineChanged();
    void cursorPositionChanged();

private slots:
    void onCursorPositionChanged(const QTextCursor &cursor);

private:
    ScriptSyntaxHighlighterPrivate *m_highlighter = nullptr;
    QQuickTextDocument* m_document = nullptr;
    CompletionModel* m_completionModel = nullptr;
    CompletionProxyModel* m_proxyModel = nullptr;
    Engine *m_engine = nullptr;
    QTextCursor m_currentCursor;

    QHash<QString, QStringList> m_classes;
};


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
    CompletionModel(QObject *parent = nullptr): QAbstractListModel(parent) {}

    int rowCount(const QModelIndex &parent = QModelIndex()) const override {
        Q_UNUSED(parent)
        return m_list.count();
    }
    QHash<int, QByteArray> roleNames() const override {
        QHash<int, QByteArray> roles;
        roles.insert(Qt::UserRole, "text");
        roles.insert(Qt::DisplayRole, "displayText");
        return roles;
    }
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override {
        Q_UNUSED(role)
        switch (role) {
        case Qt::UserRole:
            return m_list.at(index.row()).text;
        case Qt::DisplayRole:
            return m_list.at(index.row()).displayText;
        }
        return QVariant();
    }
    void clear() {
        beginResetModel();
        m_list.clear();
        endResetModel();
        emit countChanged();
    }
    void append(const Entry &entry) {
        beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
        m_list.append(entry);
        endInsertRows();
        emit countChanged();
    }
    Entry get(int index) {
        return m_list.at(index);
    }
signals:
    void countChanged();
private:
    QList<Entry> m_list;
};

class CompletionProxyModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)
public:
    CompletionProxyModel(CompletionModel *model, QObject *parent = nullptr): QSortFilterProxyModel(parent), m_model(model) {
        setSourceModel(model);
        connect(model, &CompletionModel::countChanged, this, &CompletionProxyModel::countChanged);
        sort(0);
    }

    CompletionModel::Entry get(int index) {
        return m_model->get(mapToSource(this->index(index, 0)).row());
    }

    QString filter() const {
        return m_filter;
    }
    void setFilter(const QString &filter) {
        if (m_filter != filter) {
            m_filter = filter;
            emit filterChanged();
            invalidateFilter();
            emit countChanged();
        }
    }
protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &/*source_parent*/) const override {
        if (!m_filter.isEmpty()) {
            CompletionModel::Entry entry = m_model->get(source_row);
            if (!entry.displayText.startsWith(m_filter) && !entry.text.startsWith(m_filter)) {
                return false;
            }
        }
        return true;
    }
signals:
    void filterChanged();
    void countChanged();
private:
    CompletionModel *m_model = nullptr;
    QString m_filter;
};

#endif // SCRIPTSYNTAXHIGHLIGHTER_H
