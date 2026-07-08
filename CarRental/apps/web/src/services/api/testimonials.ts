import api from './axios';

export const testimonialService = {
  getTestimonials: async () => {
    const { data } = await api.get('/testimonials/');
    return data;
  },
};
