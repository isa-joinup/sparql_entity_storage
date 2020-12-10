<?php

declare(strict_types = 1);

namespace Drupal\sparql_entity_storage\Exception;

/**
 * Used when a new a SPARQL entity tries to use an existing ID.
 */
class DuplicatedIdException extends \Exception {}
