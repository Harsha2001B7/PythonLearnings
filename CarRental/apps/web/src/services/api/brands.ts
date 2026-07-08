import api from './axios';

export const brandService = {
  getBrands: async () => {
    const { data } = await api.get('/brands/');
    return data;
  },
};
