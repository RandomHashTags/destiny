import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  // A number specifying the number of VUs to run concurrently.
  vus: 900,
  // A string specifying the total duration of the test run.
  duration: '60s',
};

export default function() {
  http.get('http://192.168.1.174:8080/html');
  sleep(1);
}
