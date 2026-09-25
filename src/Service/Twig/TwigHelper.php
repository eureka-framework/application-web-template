<?php

/*
 * Copyright (c) Romain Cottard
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

declare(strict_types=1);

namespace Application\Service\Twig;

use Symfony\Component\Routing\Router;

class TwigHelper
{
    /** @var array<string, string> $assetsManifest */
    private array $assetsManifest;

    public function __construct(
        private readonly Router $router,
        private readonly ManifestLoader $manifestLoader,
        private readonly string $webAssetsPath,
    ) {
        $this->assetsManifest = $this->manifestLoader->load($webAssetsPath);
    }

    /**
     * @return array<string, callable>
     */
    public function getCallbackFunctions(): array
    {
        return [
            'importmap' => $this->importmap(...),
            'path'   => $this->path(...),
            'image'  => $this->image(...),
        ];
    }

    public function importmap(string $name): string
    {
        $importMapGenerator = new TwigImportMapGenerator($name, $this->webAssetsPath);

        return
            $importMapGenerator->css()
            . $importMapGenerator->importmap()
            . $importMapGenerator->js()
        ;
    }


    /**
     * @param  array<string, string|int|float> $params
     */
    public function path(string $routeName, array $params = []): string
    {
        return $this->router->generate($routeName, $params);
    }

    public function image(string $filename): string
    {
        if (\preg_match('`([a-z]+)://(.+)`', $filename, $matches) > 0) {
            return match ($matches[1]) {
                'asset'  => $this->getRealAssetPath($matches[2], '/'),
                'image'  => $this->getRealAssetPath($matches[2], '/img/'),
                'upload' => '/upload/' . $matches[2],
                default  => $filename,
            };
        }

        return $this->getRealAssetPath($filename, '');
    }


    private function getRealAssetPath(string $filename, string $baseUrl): string
    {
        $filePath = \trim($baseUrl, ' /') . '/' . \ltrim($filename, '/');

        return $this->assetsManifest[$filePath] ?? '';
    }
}
