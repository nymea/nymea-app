#include "xyseriesadapter.h"

XYSeriesAdapter::XYSeriesAdapter(QObject *parent) : QObject(parent)
{

}

LogsModel *XYSeriesAdapter::logsModel() const
{
    return m_model;
}

void XYSeriesAdapter::setLogsModel(LogsModel *logsModel)
{
    if (m_model != logsModel) {
        m_model = logsModel;
        emit logsModelChanged();
//        update();
        connect(logsModel, &LogsModel::logEntryAdded, this, &XYSeriesAdapter::logEntryAdded);
    }
}

QtCharts::QXYSeries *XYSeriesAdapter::xySeries() const
{
    return m_series;
}

void XYSeriesAdapter::setXySeries(QtCharts::QXYSeries *series)
{
    if (m_series != series) {
        m_series = series;
        emit xySeriesChanged();
    }
}

QtCharts::QXYSeries *XYSeriesAdapter::baseSeries() const
{
    return m_baseSeries;
}

void XYSeriesAdapter::setBaseSeries(QtCharts::QXYSeries *series)
{
    if (m_baseSeries != series) {
        m_baseSeries = series;
        emit baseSeriesChanged();

        connect(m_baseSeries, &QtCharts::QXYSeries::pointAdded, this, [=](int index){
            if (m_series->count() > index) {
                m_series->replace(index, m_series->at(index).x(), calculateSampleValue(index));
            }
        });
        connect(m_baseSeries, &QtCharts::QXYSeries::pointReplaced, this, [=](int index){
            if (m_series->count() > index) {
                m_series->replace(index, m_series->at(index).x(), calculateSampleValue(index));
            }
        });
    }
}

XYSeriesAdapter::SampleRate XYSeriesAdapter::sampleRate() const
{
    return m_sampleRate;
}

void XYSeriesAdapter::setSampleRate(XYSeriesAdapter::SampleRate sampleRate)
{
    if (m_sampleRate != sampleRate) {
        m_sampleRate = sampleRate;
        emit sampleRateChanged();
    }
}

bool XYSeriesAdapter::smooth() const
{
    return m_smooth;
}

void XYSeriesAdapter::setSmooth(bool smooth)
{
    if (m_smooth != smooth) {
        m_smooth = smooth;
        emit smoothChanged();
    }
}

qreal XYSeriesAdapter::maxValue() const
{
    return m_maxValue;
}

qreal XYSeriesAdapter::minValue() const
{
    return m_minValue;
}

void XYSeriesAdapter::logEntryAdded(LogEntry *entry)
{
    if (!m_series) {
        return;
    }

    if (m_samples.isEmpty()) {
        Sample *sample = new Sample();
        sample->timestamp = entry->timestamp().addSecs(m_sampleRate);
        sample->entries.append(entry);
        sample->last = entry;
        m_newestSample = sample->timestamp;
        m_oldestSample = m_newestSample;
        m_samples.append(sample);
        m_series->insert(0, QPointF(sample->timestamp.toMSecsSinceEpoch(), entry->value().toDouble()));
        return;
    }

    while (entry->timestamp() > m_newestSample) {
        Sample *sample = new Sample();
        sample->timestamp = m_newestSample.addSecs(m_sampleRate);
        sample->last = m_samples.value(0)->last;
        m_newestSample = sample->timestamp;
        m_samples.prepend(sample);
        m_series->insert(0, QPointF(sample->timestamp.toMSecsSinceEpoch(), sample->last->value().toDouble()));
    }

    while (entry->timestamp() < m_oldestSample.addSecs(m_sampleRate)) {
        Sample *sample = new Sample();
        sample->timestamp = m_oldestSample.addSecs(-m_sampleRate);
        sample->last = entry;
        m_oldestSample = sample->timestamp;
        m_samples.append(sample);
        m_series->append(sample->timestamp.toMSecsSinceEpoch(), sample->last->value().toDouble());
    }


    int idx = entry->timestamp().secsTo(m_newestSample) / m_sampleRate;
    if (idx > m_samples.count()) {
        qWarning() << "Overflowing integer size for XYSeriesAdapter!";
        return;
    }
    Sample *sample = m_samples.at(static_cast<int>(idx));
    sample->entries.append(entry);

    qreal value = calculateSampleValue(idx);
    m_series->replace(idx, sample->timestamp.toMSecsSinceEpoch(), value);

    if (value < m_minValue) {
        m_minValue = value;
        emit minValueChanged();
    }
    if (value > m_maxValue) {
        m_maxValue = value;
        emit maxValueChanged();
    }
}

qreal XYSeriesAdapter::calculateSampleValue(int index)
{
    Sample *sample = m_samples.at(index);
    qreal value = 0;
    int count = 0;
    if (m_samples.length() > index + 1) {
        Sample *previousSample = m_samples.at(static_cast<int>(index) + 1);
        value = previousSample->last->value().toDouble();
        count++;
    }
    foreach (LogEntry *entry, sample->entries) {
        value += entry->value().toDouble();
        count++;
    }

    if (count > 1) {
        value /= count;
    }

    if (m_baseSeries && m_baseSeries->count() > index) {
        value += m_baseSeries->at(index).y();
    }

    return value;
}
