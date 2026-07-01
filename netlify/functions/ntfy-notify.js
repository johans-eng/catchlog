exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
      },
    };
  }

  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, body: 'Method not allowed' };
  }

  try {
    const payload = JSON.parse(event.body || '{}');
    const topic = payload.topic;
    const title = payload.title;
    const body = payload.body;
    const tags = payload.tags;
    const priority = payload.priority;

    if (!topic || !body) {
      return { statusCode: 400, body: 'Missing topic or body' };
    }

    const headers = {
      Title: String(title || "Jopie's Catches").slice(0, 250),
      Priority: String(priority || 'high'),
    };
    if (tags) headers.Tags = String(tags);

    const response = await fetch(
      `https://ntfy.sh/${encodeURIComponent(topic)}`,
      { method: 'POST', headers, body: String(body) },
    );

    return {
      statusCode: response.status,
      headers: { 'Content-Type': 'text/plain' },
      body: await response.text(),
    };
  } catch (err) {
    return { statusCode: 500, body: String(err) };
  }
};
