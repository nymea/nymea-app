#ifndef CODECOMPLETION_H
#define CODECOMPLETION_H

#include <QObject>
#include <QQuickTextDocument>
#include <QTextCursor>
#include <QHash>

class Engine;
class CompletionModel;
class CompletionProxyModel;

class CodeCompletion: public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(QQuickTextDocument *document READ document WRITE setDocument NOTIFY documentChanged)
    Q_PROPERTY(int cursorPosition READ cursorPosition WRITE setCursorPosition NOTIFY cursorPositionChanged)
    Q_PROPERTY(CompletionProxyModel* model READ model CONSTANT)
    Q_PROPERTY(QString currentWord READ currentWord NOTIFY currentWordChanged)

public:
    CodeCompletion(QObject *parent = nullptr);

    Engine* engine() const;
    void setEngine(Engine *engine);

    QQuickTextDocument* document() const;
    void setDocument(QQuickTextDocument *document);

    int cursorPosition() const;
    void setCursorPosition(int position);

    QString currentWord() const;

    CompletionProxyModel* model() const;

public slots:
    void update();

    void complete(int index);
    void newLine();
    void indent(int from, int to);
    void unindent(int from, int to);
    void closeBlock();
    void insertAfterCursor(const QString &text);

signals:
    void engineChanged();
    void documentChanged();
    void cursorPositionChanged();
    void currentWordChanged();

private:
    struct BlockInfo {
        QString name;
        QHash<QString, QString> properties;
    };

    BlockInfo getBlockInfo(int postition);

    template<typename T> void registerType(const QString &qmlName);

private:
    Engine *m_engine = nullptr;
    QQuickTextDocument* m_document = nullptr;
    CompletionModel *m_model = nullptr;
    CompletionProxyModel *m_proxy = nullptr;

    QTextCursor m_cursor;

    QHash<QString, QStringList> m_classes;
    QHash<QString, QString> m_genericSyntax;

};

#endif // CODECOMPLETION_H
