<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('zones_geographiques', function (Blueprint $table) {

    $table->uuid('id')->primary();

    $table->string('ville');
    $table->string('quartier');

    $table->decimal('latitude',10,7)->nullable();
    $table->decimal('longitude',10,7)->nullable();

    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('zone__geographiques');
    }
};
