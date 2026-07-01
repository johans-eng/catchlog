const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Title, Priority, Tags',
};

exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 204, headers: corsHeaders, body: '' };
  }

  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      headers: corsHeaders,
      body: 'Method Not Allowed',
    };
  }

  const topic = event.path.replace(/^.*\/ntfy-proxy\/?/, '');
  if (!topic) {
    return {
      statusCode: 400,
      headers: corsHeaders,
      body: 'Missing ntfy topic',
    };
  }

  const headers = {
    Priority: event.headers.priority || event.headers.Priority || 'high',
    Tags: event.headers.tags || event.headers.Tags || 'rotating_light',
  };
  const title = event.headers.title || event.headers.Title;
  if (title) headers.Title = title;

  const response = await fetch(`https://ntfy.sh/${topic}`, {
    method: 'POST',
    headers,
    body: event.body,
  });

  const body = await response.text();
  return {
    statusCode: response.status,
    headers: {
      ...corsHeaders,
      'Content-Type': response.headers.get('content-type') || 'application/json',
    },
    body,
  };
};
