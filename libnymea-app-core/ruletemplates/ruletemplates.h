#ifndef RULETEMPLATES_H
#define RULETEMPLATES_H

#include <QAbstractListModel>

class RuleTemplate;
class StateEvaluatorTemplate;
class DevicesProxy;

class RuleTemplates : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleDescription,
        RoleInterfaces
    };
    Q_ENUM(Roles)

    explicit RuleTemplates(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE RuleTemplate* get(int index) const;

signals:
    void countChanged();

private:
    QList<RuleTemplate*> m_list;

};

#include <QSortFilterProxyModel>

class RuleTemplatesFilterModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(RuleTemplates* ruleTemplates READ ruleTemplates WRITE setRuleTemplates NOTIFY ruleTemplatesChanged)
    Q_PROPERTY(QStringList filterInterfaceNames READ filterInterfaceNames WRITE setFilterInterfaceNames NOTIFY filterInterfaceNamesChanged)
    Q_PROPERTY(DevicesProxy* filterByDevices READ filterByDevices WRITE setFilterByDevices NOTIFY filterByDevicesChanged)

public:
    RuleTemplatesFilterModel(QObject *parent = nullptr): QSortFilterProxyModel(parent) {}
    RuleTemplates* ruleTemplates() const { return m_ruleTemplates; }
    void setRuleTemplates(RuleTemplates* ruleTemplates) { if (m_ruleTemplates != ruleTemplates) { m_ruleTemplates = ruleTemplates; setSourceModel(ruleTemplates); emit ruleTemplatesChanged(); invalidateFilter(); emit countChanged();}}
    QStringList filterInterfaceNames() const { return m_filterInterfaceNames; }
    void setFilterInterfaceNames(const QStringList &filterInterfaceNames) { if (m_filterInterfaceNames != filterInterfaceNames) { m_filterInterfaceNames = filterInterfaceNames; emit filterInterfaceNamesChanged(); invalidateFilter(); emit countChanged(); }}
    DevicesProxy* filterByDevices() const { return m_filterDevicesProxy; }
    void setFilterByDevices(DevicesProxy* filterDevicesProxy) {if (m_filterDevicesProxy !=  filterDevicesProxy) { m_filterDevicesProxy = filterDevicesProxy; emit filterByDevicesChanged(); invalidateFilter(); }}
    Q_INVOKABLE RuleTemplate* get(int index) {
        if (index < 0 || index >= rowCount()) {
            return nullptr;
        }
        return m_ruleTemplates->get(mapToSource(this->index(index, 0)).row());
    }
protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool stateEvaluatorTemplateContainsInterface(StateEvaluatorTemplate *stateEvaluatorTemplate, const QStringList &interfaceNames) const;
signals:
    void ruleTemplatesChanged();
    void filterInterfaceNamesChanged();
    void filterByDevicesChanged();
    void countChanged();
private:
    RuleTemplates* m_ruleTemplates = nullptr;
    QStringList m_filterInterfaceNames;
    DevicesProxy* m_filterDevicesProxy = nullptr;
};

#endif // RULETEMPLATES_H
