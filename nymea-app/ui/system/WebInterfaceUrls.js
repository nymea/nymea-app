// SPDX-License-Identifier: GPL-3.0-or-later
.pragma library

function hasProxy(configuration) {
    return configuration && configuration.proxyPort > 0 && configuration.proxyPort <= 65535
}

function preferred(current, candidate) {
    return current === null || (current.sslEnabled && !candidate.sslEnabled) ? candidate : current
}

function selectConfiguration(configurations, address) {
    if (!configurations || address === "")
        return null

    var proxy = null
    var exact = null
    var wildcard = null
    for (var i = 0; i < configurations.count; ++i) {
        var candidate = configurations.get(i)
        if (!candidate)
            continue
        if (hasProxy(candidate)) {
            if (proxy === null || candidate.id < proxy.id)
                proxy = candidate
        }
        if (candidate.address === address)
            exact = preferred(exact, candidate)
        else if (candidate.address === "0.0.0.0")
            wildcard = preferred(wildcard, candidate)
    }
    return proxy !== null ? proxy : (exact !== null ? exact : wildcard)
}

function interfaceUrl(address, configuration, resource) {
    if (!address || !configuration)
        return ""

    var proxy = hasProxy(configuration)
    var secure = proxy ? configuration.proxySslEnabled : configuration.sslEnabled
    var port = proxy ? configuration.proxyPort : configuration.port
    var prefix = proxy ? (configuration.proxyPathPrefix || "") : ""
    var authority = address
    if (port !== (secure ? 443 : 80))
        authority += ":" + port
    return (secure ? "https://" : "http://") + authority + prefix + "/" + resource + "/"
}
