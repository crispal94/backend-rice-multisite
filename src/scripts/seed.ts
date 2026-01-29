// @ts-nocheck
import { ExecArgs } from '@medusajs/types'
import { ContainerRegistrationKeys, Modules } from '@medusajs/utils'

export default async function ({ container }: ExecArgs) {
  // Al poner @ts-nocheck arriba, TypeScript ignorará que no sabe los tipos de estas variables
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER)
  const link = container.resolve(ContainerRegistrationKeys.REMOTE_LINK)

  // 1. Invocamos a los 3 Jefes: Producto, Precios y Canales
  const productService = container.resolve(Modules.PRODUCT)
  const pricingService = container.resolve(Modules.PRICING)
  const salesChannelService = container.resolve(Modules.SALES_CHANNEL)

  logger.info('🚜 Iniciando sembrado avanzado (V2 Architecture)...')

  // --- A. Obtener Canal de Ventas ---
  const [defaultSalesChannel] = await salesChannelService.listSalesChannels({
    name: 'Default Sales Channel'
  })

  if (!defaultSalesChannel) {
    logger.error(
      '❌ Error: No existe el Default Sales Channel. Ejecuta las migraciones primero.'
    )
    return
  }

  // --- B. Crear el Producto (El Arroz) ---
  // Nota: Aquí NO ponemos el precio. Solo el producto físico.
  const [arroz] = await productService.createProducts([
    {
      title: 'Arroz Super Extra (Seed)',
      handle: 'arroz-super-seed',
      description: 'Producto creado automáticamente con precio vinculado.',
      options: [{ title: 'Presentación', values: ['Saco 50kg'] }],
      variants: [
        {
          title: 'Saco 50kg',
          sku: 'SEED-001',
          options: { Presentación: 'Saco 50kg' }
        }
      ]
    }
  ])

  const variantId = arroz.variants[0].id
  logger.info(`✅ Producto creado: ${arroz.title} (ID Variante: ${variantId})`)

  // --- C. Crear el Precio (El Dinero) ---
  // Creamos un "PriceSet". Piensa en esto como una etiqueta de precio inteligente.
  const [priceSet] = await pricingService.createPriceSets([
    {
      prices: [
        {
          amount: 45, // $45.00
          currency_code: 'usd',
          rules: {} // Aquí irían reglas complejas si las hubiera
        }
      ]
    }
  ])
  logger.info(`💰 Precio creado en USD: $45.00`)

  // --- D. Construir los Puentes (Links) ---

  // Puente 1: Producto <--> Canal de Ventas (Para que se vea en la web)
  await link.create([
    {
      [Modules.PRODUCT]: { product_id: arroz.id },
      [Modules.SALES_CHANNEL]: { sales_channel_id: defaultSalesChannel.id }
    }
  ])

  // Puente 2: Variante <--> Precio (Para que el dashboard no explote)
  // IMPORTANTE: Este es el link que faltaba antes
  await link.create([
    {
      [Modules.PRODUCT]: { variant_id: variantId },
      [Modules.PRICING]: { price_set_id: priceSet.id }
    }
  ])

  logger.info('🔗 Puentes construidos. El sembrado ha terminado con éxito.')
}
