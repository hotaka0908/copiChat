import { MetadataRoute } from 'next'
import { getAllPersonas } from '@/lib/personas'

export default function sitemap(): MetadataRoute.Sitemap {
  const personas = getAllPersonas()
  const baseUrl = 'https://dtalk-5u4qk19dd-hotakas-projects.vercel.app'
  
  // 基本ページ
  const routes = [
    {
      url: baseUrl,
      lastModified: new Date(),
      changeFrequency: 'daily' as const,
      priority: 1,
    },
  ]
  
  // 各人物のチャットページを追加
  personas.forEach((persona) => {
    routes.push({
      url: `${baseUrl}/chat/${persona.id}`,
      lastModified: new Date(),
      changeFrequency: 'daily' as const,
      priority: 0.8,
    })
  })
  
  return routes
}