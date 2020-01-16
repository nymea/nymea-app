#ifndef SCRIPTSYNTAXHIGHLIGHTER_H
#define SCRIPTSYNTAXHIGHLIGHTER_H

#include <QObject>
#include <QSyntaxHighlighter>
#include <QQuickTextDocument>

class ScriptSyntaxHighlighterPrivate;
class CompletionModel;
class CompletionProxyModel;

class ScriptSyntaxHighlighter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQuickTextDocument* document READ document WRITE setDocument NOTIFY documentChanged)
    Q_PROPERTY(QColor backgroundColor READ backgroundColor WRITE setBackgroundColor NOTIFY backgroundColorChanged)
public:

    explicit ScriptSyntaxHighlighter(QObject *parent = nullptr);

    QQuickTextDocument* document() const;
    void setDocument(QQuickTextDocument *document);

    QColor backgroundColor() const;
    void setBackgroundColor(const QColor &backgroundColor);

signals:
    void documentChanged();
    void backgroundColorChanged();

private:
    ScriptSyntaxHighlighterPrivate *m_highlighter = nullptr;
    QQuickTextDocument* m_document = nullptr;
    QColor m_backgroundColor;
};

#endif // SCRIPTSYNTAXHIGHLIGHTER_H
