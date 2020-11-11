#ifndef ZIGBEENETWORKSANDADAPTERS_H
#define ZIGBEENETWORKSANDADAPTERS_H

#include <QAbstractListModel>

class ZigbeeManager;

class ZigbeeNetworksAndAdapters : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit ZigbeeNetworksAndAdapters(ZigbeeManager *manager);

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;

signals:

private:
    ZigbeeManager *m_manager = nullptr;

//    QList<
};

#endif // ZIGBEENETWORKSANDADAPTERS_H
