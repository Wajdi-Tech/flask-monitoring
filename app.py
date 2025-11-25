from flask import Flask
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)

# Métriques personnalisées
by_path_counter = metrics.counter(
    'by_path_counter', 'Request count by request paths',
    labels={'path': lambda: request.path}
)

@app.route('/')
@by_path_counter
def hello():
        return "<h1>CI/CD 100% OK – 11:21:45 – 25/11/2025</h1>", 200

@app.route('/health')
def health():
        return "<h1>CI/CD 100% OK – 11:21:45 – 25/11/2025</h1>", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
