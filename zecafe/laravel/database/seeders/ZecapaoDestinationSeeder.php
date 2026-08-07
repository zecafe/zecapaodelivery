<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class ZecapaoDestinationSeeder extends Seeder
{
    public function run(): void
    {
        $tenantId = DB::table('tenants')->insertGetId([
            'name' => 'Zecapão Delivery', 'slug' => 'zecapao', 'active' => 1,
            'created_at' => now(), 'updated_at' => now(),
        ]);

        $destinationId = DB::table('destinations')->insertGetId([
            'tenant_id' => $tenantId, 'name' => 'Vale do Capão', 'slug' => 'vale-do-capao',
            'city' => 'Palmeiras', 'state' => 'BA', 'country_code' => 'BR', 'active' => 1,
            'brand_primary' => '#E72E27', 'brand_secondary' => '#FEC90F',
            'created_at' => now(), 'updated_at' => now(),
        ]);

        $types = [
            ['Comer & Beber','food'], ['Mercados','markets'], ['Lojas','shops'],
            ['Hospedagem','lodging'], ['Passeios & Experiências','experiences'],
            ['Turismo & Serviços','services'], ['Eventos','events'],
        ];
        foreach ($types as [$name, $slug]) {
            DB::table('business_types')->updateOrInsert(
                ['slug' => $slug],
                ['name' => $name, 'active' => 1, 'created_at' => now(), 'updated_at' => now()]
            );
        }

        DB::table('destination_events')->updateOrInsert(
            ['destination_id' => $destinationId, 'slug' => 'capao-reggae-vale'],
            [
                'name' => 'Capão Reggae Vale',
                'image' => 'zecapao/events/capao_reggae_vale.jpg',
                'featured' => 1, 'active' => 1,
                'metadata' => json_encode(['source' => 'campaign_asset', 'editable_fields' => ['starts_at','venue','ticket_url','cta_label']]),
                'created_at' => now(), 'updated_at' => now(),
            ]
        );
    }
}
