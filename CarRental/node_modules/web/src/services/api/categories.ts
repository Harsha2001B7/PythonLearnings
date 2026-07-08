import api from './axios';

export const categoryService = {
  getCategories: async () => {
    const { data } = await api.get('/categories/');
    return data;
  },
};
