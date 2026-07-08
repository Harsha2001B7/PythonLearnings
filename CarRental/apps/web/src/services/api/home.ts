import api from './axios';

export const homeService = {
  getHomeData: async () => {
    const { data } = await api.get('/home/');
    return data;
  },
};
