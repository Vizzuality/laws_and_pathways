import get from 'lodash/get';

const MIN_ZOOM = 1;
const MAX_ZOOM = 12;

export const initialState = {
  zoom: 1,
  center: [0, 0],
  geos: [],
  data: {},
  selectedContextId: undefined,
  selectedContentId: undefined,
  tooltipGeography: undefined,
  countryHighlighted: ''
};

export default function worldMapReducer(state, action) {
  switch (action.type) {
    case 'zoomIn': {
      return { ...state, zoom: Math.min(state.zoom + 1, MAX_ZOOM) };
    }
    case 'zoomOut': {
      return { ...state, zoom: Math.max(state.zoom - 1, MIN_ZOOM) };
    }
    case 'zoomEnd': {
      const { zoom } = action.payload;
      return {
        ...state,
        zoom: Math.min(zoom, MAX_ZOOM)
      };
    }
    case 'setData': {
      const selectedContextId = get(action.payload, 'context[0].id');
      const selectedContentId = get(action.payload, 'content[0].id');

      return { ...state, selectedContextId, selectedContentId, data: action.payload };
    }
    case 'setGeos': {
      return { ...state, geos: action.payload };
    }
    case 'setCenter': {
      return { ...state, center: action.payload };
    }
    case 'setContextId': {
      return { ...state, selectedContextId: action.payload };
    }
    case 'setContentId': {
      return { ...state, selectedContentId: action.payload };
    }
    case 'setTooltipGeography': {
      return { ...state, tooltipGeography: action.payload };
    }
    case 'setCountryHighlighted': {
      return { ...state, countryHighlighted: action.payload };
    }
    default:
      return state;
  }
}
