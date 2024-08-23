from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/api/greet', methods=['GET'])
def greet():
    return jsonify({"message": "Hello, World!"})

if __name__ == '__main__':
    app.run(host='13.233.58.239', port=5000)
