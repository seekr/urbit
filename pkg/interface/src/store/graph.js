import GraphReducer from '../reducers/graph-update';

import BaseStore from './base';


export default class GraphStore extends BaseStore {
  constructor() {
    super();
    this.graphReducer = new GraphReducer();
    //this.perf = performance.now();
  }

  initialState() {
    return {
      keys: new Set([]),
      graphs: {},
      sidebarShown: true,
    };
  }

  reduce(data, state) {
    this.graphReducer.reduce(data, this.state);
    //console.log(data, state);
    /*let perf = performance.now();
    console.log(perf - this.perf);
    this.perf = perf;*/
  }
}
