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

function interfaceRank(kind) {
    var ranks = ["ethernet", "wifi", "vlan", "bridge", "tun", "tap"]
    var rank = ranks.indexOf(kind)
    return rank >= 0 ? rank : ranks.length
}

// Picks the IPv4 address of the most relevant connected interface from a NetworkInterfaces model
function interfaceAddress(interfaces) {
    if (!interfaces)
        return ""

    var best = ""
    var bestRank = -1
    for (var i = 0; i < interfaces.count; ++i) {
        var networkInterface = interfaces.get(i)
        if (!networkInterface || networkInterface.kind === "loopback")
            continue
        if (["down", "off", "no-carrier"].indexOf(networkInterface.operationalState) >= 0)
            continue

        var rank = interfaceRank(networkInterface.kind)
        if (best !== "" && rank >= bestRank)
            continue

        var addresses = networkInterface.ipv4Addresses || []
        for (var j = 0; j < addresses.length; ++j) {
            var address = addresses[j].address
            if (address && address.indexOf("169.254.") !== 0) {
                best = address
                bestRank = rank
                break
            }
        }
    }
    return best
}

function isIpv4Address(host) {
    var match = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/.exec(host || "")
    if (!match)
        return false
    for (var i = 1; i <= 4; ++i) {
        if (parseInt(match[i], 10) > 255)
            return false
    }
    return true
}
