import { Handler, Context, CloudWatchLogsEvent } from 'aws-lambda';
import axios, { RawAxiosRequestHeaders } from 'axios';

const chanify_token = process.env.CHANIFY_TOKEN;
const nasa_token = process.env.NASA_API_KEY;
const chanify_url = `https://api.chanify.net/v1/sender/${chanify_token}`;
const nasa_url = 'https://api.nasa.gov/planetary/apod';

const getNasaPicture = async () => {
  return (await axios.get(nasa_url, {
    params: {
      api_key: nasa_token
    }
  })).data
}

const sendChanifyMessage = async (data: any, headers: RawAxiosRequestHeaders = {}) => {
  try {
    await axios.post(chanify_url, data, {
      headers
    });
    return
  }
  catch (err) {
    console.error(err);
  }
}

export const chanifyHandler: Handler<CloudWatchLogsEvent> = async (event, context) => {
  try {
    const data = await getNasaPicture();
    await sendChanifyMessage({
      title: 'NASA photo of the day',
      text: data.title,
      actions: [`See photo|${data.url}`]
    });
  }
  catch (err) {
    console.error(err);
  }
}

// for testing purposes only
if (require.main) {
  chanifyHandler({} as CloudWatchLogsEvent, {} as Context, () => {})
    // @ts-ignore
    .then(() => {
      console.log('finished');
    })
    .catch((err: any) => {
      console.error("err", err)
    })
}