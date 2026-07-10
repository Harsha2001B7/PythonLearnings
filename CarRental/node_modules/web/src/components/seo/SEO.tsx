import React from 'react';
import { Helmet } from 'react-helmet-async';

interface SEOProps {
  title?: string;
  description?: string;
  keywords?: string;
  canonicalUrl?: string;
  ogType?: 'website' | 'article' | 'product';
  ogImage?: string;
  twitterCard?: 'summary' | 'summary_large_image';
  jsonLd?: Record<string, any> | Record<string, any>[];
  children?: React.ReactNode;
}

const DEFAULT_TITLE = "Falcon View Car Rentals — Drive Dubai. Delivered to you.";
const DEFAULT_DESCRIPTION = "Sedans, SUVs and 7-seaters on daily, weekly or monthly plans. Free delivery across Dubai. Book via WhatsApp in minutes.";
const DEFAULT_KEYWORDS = "car rental Dubai, SUV rental Dubai, 7 seater rental UAE, Nissan Patrol rental, Dodge Challenger Dubai, cheap car rental Dubai";
const DEFAULT_IMAGE = "https://falconviewcarrentals.com/falconviewbackground.png"; // Placeholder
const SITE_URL = "https://falconviewcarrentals.com";

const SEO: React.FC<SEOProps> = ({
  title,
  description,
  keywords,
  canonicalUrl,
  ogType = 'website',
  ogImage = DEFAULT_IMAGE,
  twitterCard = 'summary_large_image',
  jsonLd,
  children
}) => {
  const seoTitle = title ? `${title} | Falcon View Car Rentals` : DEFAULT_TITLE;
  const seoDescription = description || DEFAULT_DESCRIPTION;
  const seoKeywords = keywords || DEFAULT_KEYWORDS;
  const url = canonicalUrl ? `${SITE_URL}${canonicalUrl}` : SITE_URL;

  return (
    <Helmet>
      {/* Standard Metadata */}
      <title>{seoTitle}</title>
      <meta name="description" content={seoDescription} />
      <meta name="keywords" content={seoKeywords} />

      {/* Canonical Link */}
      <link rel="canonical" href={url} />

      {/* Open Graph Metadata */}
      <meta property="og:title" content={seoTitle} />
      <meta property="og:description" content={seoDescription} />
      <meta property="og:type" content={ogType} />
      <meta property="og:url" content={url} />
      <meta property="og:image" content={ogImage} />
      <meta property="og:site_name" content="Falcon View Car Rentals" />

      {/* Twitter Card Metadata */}
      <meta name="twitter:card" content={twitterCard} />
      <meta name="twitter:title" content={seoTitle} />
      <meta name="twitter:description" content={seoDescription} />
      <meta name="twitter:image" content={ogImage} />

      {/* JSON-LD Structured Data */}
      {jsonLd && (
        <script type="application/ld+json">
          {JSON.stringify(jsonLd)}
        </script>
      )}
      
      {children}
    </Helmet>
  );
};

export default SEO;
