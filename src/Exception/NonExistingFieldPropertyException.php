<?php

declare(strict_types = 1);

namespace Drupal\sparql_entity_storage\Exception;

/**
 * Thrown when trying to write to a non-existing field property.
 */
class NonExistingFieldPropertyException extends \Exception {}
