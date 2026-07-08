import api from './axios';

export const faqService = {
  getFaqs: async () => {
    const { data } = await api.get('/faqs/');
    return data;
  },
};
