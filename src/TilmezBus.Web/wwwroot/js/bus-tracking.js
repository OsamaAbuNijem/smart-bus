// TilmezBus — Real-time bus tracking via SignalR + OpenStreetMap (Leaflet)

const token = document.cookie.split('; ').find(r => r.startsWith('JwtToken='))?.split('=')[1]
    || sessionStorage.getItem('JwtToken');

const map = L.map('map').setView([31.9539, 35.9106], 12);  // Default: Amman, Jordan
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    maxZoom: 19
}).addTo(map);

const busMarkers = {};
let notificationCount = 0;

// Custom bus icon
const busIcon = L.divIcon({
    html: '<i class="bi bi-bus-front-fill text-primary" style="font-size:24px;"></i>',
    className: '',
    iconSize: [24, 24],
    iconAnchor: [12, 12]
});

// Connect to SignalR hub
const connection = new signalR.HubConnectionBuilder()
    .withUrl('/hubs/bus-tracking', {
        accessTokenFactory: () => sessionStorage.getItem('JwtToken') || ''
    })
    .withAutomaticReconnect()
    .configureLogging(signalR.LogLevel.Warning)
    .build();

connection.on('BusLocationUpdated', (data) => {
    const { busId, latitude, longitude, speed } = data;
    const label = speed ? `Speed: ${speed.toFixed(1)} km/h` : 'Live';

    if (busMarkers[busId]) {
        busMarkers[busId].setLatLng([latitude, longitude]);
        busMarkers[busId].setPopupContent(`<b>Bus ${busId.substring(0, 8)}...</b><br/>${label}`);
    } else {
        busMarkers[busId] = L.marker([latitude, longitude], { icon: busIcon })
            .addTo(map)
            .bindPopup(`<b>Bus ${busId.substring(0, 8)}...</b><br/>${label}`);
    }
});

connection.on('TripStatusUpdated', (data) => {
    addNotification('Trip Update', `Trip ${data.tripId.substring(0, 8)}... is now ${data.status}`, 'info');
});

connection.on('ReceiveNotification', (data) => {
    addNotification(data.title, data.message, 'success');
});

function addNotification(title, message, type = 'info') {
    notificationCount++;
    document.getElementById('notification-count').textContent = notificationCount;

    const feed = document.getElementById('notification-feed');
    const placeholder = feed.querySelector('p.text-muted');
    if (placeholder) placeholder.remove();

    const icons = { info: 'info-circle', success: 'check-circle', warning: 'exclamation-triangle' };
    const colors = { info: 'primary', success: 'success', warning: 'warning' };

    const item = document.createElement('div');
    item.className = `alert alert-${colors[type]} alert-dismissible py-2 px-3 mb-2`;
    item.innerHTML = `
        <i class="bi bi-${icons[type]} me-2"></i>
        <strong>${title}</strong><br/>
        <small>${message}</small>
        <small class="d-block text-muted mt-1">${new Date().toLocaleTimeString()}</small>
        <button type="button" class="btn-close py-2" data-bs-dismiss="alert"></button>`;
    feed.prepend(item);
}

async function startSignalR() {
    try {
        await connection.start();
        await connection.invoke('JoinAdminGroup');
        console.log('TilmezBus SignalR connected');
    } catch (err) {
        console.warn('SignalR connection failed, retrying in 5s...', err);
        setTimeout(startSignalR, 5000);
    }
}

startSignalR();
