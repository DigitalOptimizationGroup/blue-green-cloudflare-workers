// canary config
export const config = {
  defaultBackend: `https://${process.env.BLUE_DOMAIN}`,

  // turn on canary deployment
  canary: true,

  // set the percent of traffic to send to the canary from 0-100
  // note that you should only increase this number when shifting traffic to assure
  // that your users to not "jump around" between backends
  weight: 50,
  canaryBackend: `https://${process.env.GREEN_DOMAIN}`,

  // you should change this salt for every new canary release so that users are
  // not allocated in the same manner as previous deployments
  salt: "canary-abc-123",

  // default is false, if true proxy will set _vq cookie for consistent assignment to same backend
  setCookie: true
};
