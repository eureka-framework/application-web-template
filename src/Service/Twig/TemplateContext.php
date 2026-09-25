<?php

/*
 * Copyright (c) Romain Cottard
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

declare(strict_types=1);

namespace Application\Service\Twig;

class TemplateContext
{
    /** @phpstan-var array<string, mixed> $collection */
    private array $collection;

    public function __construct()
    {
        $this->collection = [];
    }

    /**
     * @phpstan-param  mixed $value
     */
    public function add(string $name, $value): self
    {
        $this->collection[$name] = $value;

        return $this;
    }

    /**
     * @phpstan-param  array<string, mixed> $collection
     */
    public function addCollection(array $collection): self
    {
        foreach ($collection as $name => $value) {
            $this->add($name, $value);
        }

        return $this;
    }

    public function has(string $name): bool
    {
        return \array_key_exists($name, $this->collection);
    }

    /**
     * @phpstan-return mixed
     */
    public function get(string $name): mixed
    {
        return $this->collection[$name];
    }

    /**
     * @phpstan-return array<string, mixed>
     */
    public function getAll(): array
    {
        return $this->collection;
    }
}
