<?php

declare(strict_types = 1);

namespace Drupal\sparql_entity_storage\Event;

/**
 * An event dispatched when a value is being prepared for storage.
 */
class OutboundValueEvent extends ValueEventBase {}
