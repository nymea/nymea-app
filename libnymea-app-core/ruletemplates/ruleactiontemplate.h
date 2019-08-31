#ifndef RULEACTIONTEMPLATE_H
#define RULEACTIONTEMPLATE_H

#include <QObject>

class RuleActionParamTemplates;

class RuleActionTemplate : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString interfaceName READ interfaceName CONSTANT)
    Q_PROPERTY(QString interfaceAction READ interfaceAction CONSTANT)
    Q_PROPERTY(int selectionId READ selectionId CONSTANT)
    Q_PROPERTY(SelectionMode selectionMode READ selectionMode CONSTANT)
    Q_PROPERTY(RuleActionParamTemplates* ruleActionParamTemplates READ ruleActionParamTemplates CONSTANT)

public:
    enum SelectionMode {
        SelectionModeAny,
        SelectionModeDevice,
        SelectionModeInterface
    };
    Q_ENUM(SelectionMode)

    explicit RuleActionTemplate(const QString &interfaceName, const QString &interfaceAction, int selectionId, SelectionMode selectionMode = SelectionModeAny, RuleActionParamTemplates *params = nullptr, QObject *parent = nullptr);

    QString interfaceName() const;
    QString interfaceAction() const;
    int selectionId() const;
    SelectionMode selectionMode() const;
    RuleActionParamTemplates* ruleActionParamTemplates() const;

private:
    QString m_interfaceName;
    QString m_interfaceAction;
    int m_selectionId = 0;
    SelectionMode m_selectionMode = SelectionModeAny;
    RuleActionParamTemplates* m_ruleActionParamTemplates = nullptr;
};

#include <QAbstractListModel>

class RuleActionTemplates: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QStringList interfaces READ interfaces CONSTANT)
public:
    RuleActionTemplates(QObject *parent = nullptr): QAbstractListModel(parent) {}
    int rowCount(const QModelIndex &parent = QModelIndex()) const override { Q_UNUSED(parent); return m_list.count(); }
    QVariant data(const QModelIndex &index, int role) const override { Q_UNUSED(index); Q_UNUSED(role); return QVariant(); }
    QStringList interfaces() const;

    void addRuleActionTemplate(RuleActionTemplate* ruleActionTemplate) {
        ruleActionTemplate->setParent(this);
        beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
        m_list.append(ruleActionTemplate);
        endInsertRows();
        emit countChanged();
    }

    Q_INVOKABLE RuleActionTemplate* get(int index) const {
        if (index < 0 || index >= m_list.count()) {
            return nullptr;
        }
        return m_list.at(index);
    }

signals:
    void countChanged();

private:
    QList<RuleActionTemplate*> m_list;
};

#endif // RULEACTIONTEMPLATE_H
